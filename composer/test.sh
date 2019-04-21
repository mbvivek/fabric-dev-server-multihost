HOSTS=( "127.0.0.1" "127.0.0.2" "127.0.0.3" )

for host in "${HOSTS[@]}"
do
    echo "Preparing config for HOST - ${host}"
done

cat <<EOF >test.json
{
    "hosts": "Array - ${HOSTS[@]}"
}