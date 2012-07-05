if [ -z $1 ]
then
  echo "Missing remote host"
  exit 1
fi

echo "Deploying to $1"
scp remote_you-dl.sh $1:~
scp ../youtube-dl/youtube-dl $1:~
ssh $1 "chmod 700 remote_you-dl.sh && chmod 700 youtube-dl"

