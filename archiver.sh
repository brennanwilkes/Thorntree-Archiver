
root_forum="australasia-pacific-pacific-islands-papua-new-guinea"
webpage="https://www.lonelyplanet.com/thorntree/forums/$root_forum?page="
current_page=1
max_page=797

output_path="~/Desktop/thorntree-archive"


[ -d "$output_path" ] || {
	eval mkdir -p "$output_path"
}












#| grep -o '/thorntree/[^".#?]*'




for i in $(seq $current_page $max_page); do
	current_page=$i
	curl -Ls "$webpage$current_page" | grep -o 'href="[^"]*"' | grep -v '[#?:]' | sed -n -e "s/^.*href=\"\/thorntree\/forums\/$root_forum\///p" | sed 's/"//g' | grep -v '^topics/new$' >> test.txt
done
