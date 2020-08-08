
root_forum="australasia-pacific-pacific-islands-papua-new-guinea"
webpage="https://www.lonelyplanet.com/thorntree/forums/"
current_page=1
max_page=797

output_path="~/Desktop/thorntree-archive"
output_path=$( eval echo -n "~/Desktop/thorntree-archive" )


[ -d "$output_path" ] || {
	mkdir -p "$output_path"
}

function debug_print() {
	[ "$#" -eq 4 ] && {
		printf "[%-7s] | %-38s | %-11s | %s\n" "$1" "$2" "$3" "$4"
	} || {
		printf "[%-7s] | %-52s | %s\n" "$1" "$2" "$3"
	}

}

function get_forum_posts_from_page() {
	curl -Ls "${webpage}${root_forum}?page=${1}" | grep -o 'href="[^"]*"' | grep -v '[#?:]' | sed -n -e "s/^.*href=\"\/thorntree\/forums\/$root_forum\///p" | sed 's/"//g' | grep -v '^topics/new$'
}

function extract_middle() {
	prefix=$1
	group=$2
	postfix=$3
	while IFS= read -r line; do
		echo $line | grep -E -o "$prefix$group$postfix" | sed -E "s/$prefix($group)$postfix/\1/"
	done
}

function format_file() {
	fn="$1"
	title=$( head -n 1 "$fn" | extract_middle '<h1 class="topic__title copy--h1">' '[^<]+' '<\/h1>' | tr -dc "[ \-0-9a-zA-Z]" )
	sed -i "s/<title>.*<\/title>/<title>$title<\/title>/" "$fn"
	[ $? -eq 0 ] || {
		debug_print "FAILURE" "Formatting failed for document" "$title - $fn"
	}
}

for file in $( find . | grep '.html$' ); do
	format_file $file
done


for page in $(seq $current_page $max_page); do
	debug_print "INDEX" "$root_forum" "$page/$max_page"

	for forum in $( get_forum_posts_from_page $page ); do
		sub_forum=$( echo $forum | cut -d'/' -f1 )
		page_name=$( echo $forum | cut -d'/' -f2 )
		req_page="${webpage}${root_forum}/topics/${page_name}/compact?"


		curl -Is $req_page | head -n1 | grep -q '200'
		[ $? -eq 0 ] || {
			error_code=$( curl -Is $req_page | head -n1 | cut -d' ' -f2 )
			debug_print "FAILED" "ERROR CODE: $error_code" "$req_page"
			continue
		}

		page_HTML=$( curl -Ls $req_page )
		page_date=$( echo $page_HTML | extract_middle '<small class="timeago">' '[0-9]+ [a-zA-Z]+ [0-9]+' '<\/small>' | tail -n1 )

		[ -d "${output_path}/${sub_forum}" ] || {
			mkdir -p "${output_path}/${sub_forum}"
		}


		echo "$page_HTML" > "${output_path}/${sub_forum}/${page_name}.html"
		format_file "${output_path}/${sub_forum}/${page_name}.html"
		touch -d "$page_date" "${output_path}/${sub_forum}/${page_name}.html"

		debug_print "SUCCESS" "$sub_forum" "$page_date" "$page_name"

	done
done
