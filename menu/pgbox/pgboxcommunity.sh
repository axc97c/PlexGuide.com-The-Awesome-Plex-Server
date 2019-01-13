#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

# FUNCTIONS START ##############################################################
source /opt/plexguide/menu/functions/functions.sh

queued () {
echo
read -p '⛔️ ERROR - APP Already Queued! | Press [ENTER] ' typed < /dev/tty
question1
}

exists () {
echo ""
echo "⛔️ ERROR - APP Already Installed!"
read -p '⚠️  Do You Want To ReInstall ~ y or n | Press [ENTER] ' foo < /dev/tty

if [ "$foo" == "y" ]; then part1;
elif [ "$foo" == "n" ]; then question1;
else exists; fi
}

cronexe () {
croncheck=$(cat /opt/plexguide/containers/_cron.list | grep -c "\<$p\>")
if [ "$croncheck" == "0" ]; then bash /opt/plexguide/menu/cron/cron.sh; fi
}

cronmass () {
croncheck=$(cat /opt/plexguide/containers/_cron.list | grep -c "\<$p\>")
if [ "$croncheck" == "0" ]; then bash /opt/plexguide/menu/cron/cron.sh; fi
}

initial () {
  rm -rf /var/plexguide/pgbox.output 1>/dev/null 2>&1
  rm -rf /var/plexguide/pgbox.buildup 1>/dev/null 2>&1
  rm -rf /var/plexguide/program.temp 1>/dev/null 2>&1
  rm -rf /var/plexguide/app.list 1>/dev/null 2>&1
  touch /var/plexguide/pgbox.output
  touch /var/plexguide/program.temp
  touch /var/plexguide/app.list
  touch /var/plexguide/pgbox.buildup

  mkdir -p /opt/communityapps


  if [ "$boxversion" == "official" ]; then ansible-playbook /opt/plexguide/menu/pgbox/pgboxcommunity.yml
  else ansible-playbook /opt/plexguide/menu/pgbox/pgbox_communitypersonal.yml; fi

  echo ""
  echo "💬  Pulling Update Files - Please Wait"
  file="/opt/communityapps/place.holder"
  waitvar=0
  while [ "$waitvar" == "0" ]; do
  	sleep .5
  	if [ -e "$file" ]; then waitvar=1; fi
  done

}

question1 () {

  ### Remove Running Apps
  while read p; do
    sed -i "/^$p\b/Id" /var/plexguide/app.list
  done </var/plexguide/pgbox.running

  cp /var/plexguide/app.list /var/plexguide/app.list2

  file="/var/plexguide/community.app"
  #if [ ! -e "$file" ]; then
    ls -la /opt/communityapps/apps | sed -e 's/.yml//g' \
    | awk '{print $9}' | tail -n +4  > /var/plexguide/app.list
  while read p; do
    echo "" >> /opt/communityapps/apps/$p.yml
    echo "##PG-Community" >> /opt/communityapps/apps/$p.yml

    mkdir -p /opt/mycontainers
    touch /opt/appdata/plexguide/rclone.conf
    rclone --config /opt/appdata/plexguide/rclone.conf copy /opt/communityapps/apps/ /opt/plexguide/containers
  done </var/plexguide/app.list
    touch /var/plexguide/community.app
  #fi

#bash /opt/plexguide/containers/_appsgen.sh
docker ps | awk '{print $NF}' | tail -n +2 > /var/plexguide/pgbox.running

### Remove Official Apps
while read p; do
  # reminder, need one for custom apps
  baseline=$(cat /opt/plexguide/containers/$p.yml | grep "##PG-Community")
  if [ "$baseline" == "" ]; then sed -i -e "/$p/d" /var/plexguide/app.list; fi
done </var/plexguide/app.list

### Blank Out Temp List
rm -rf /var/plexguide/program.temp && touch /var/plexguide/program.temp

### List Out Apps In Readable Order (One's Not Installed)
num=0
while read p; do
  echo -n $p >> /var/plexguide/program.temp
  echo -n " " >> /var/plexguide/program.temp
  num=$[num+1]
  if [ "$num" == 7 ]; then
    num=0
    echo " " >> /var/plexguide/program.temp
  fi
done </var/plexguide/app.list

notrun=$(cat /var/plexguide/program.temp)
buildup=$(cat /var/plexguide/pgbox.output)

if [ "$buildup" == "" ]; then buildup="NONE"; fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PGBox ~ Multi-App Installer           📓 Reference: pgbox.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Potential Apps to Install

$notrun

💾 Apps Queued for Installation

$buildup

💬 Quitting? TYPE > exit | 💪 Ready to Backup? TYPE > deploy
EOF
read -p '🌍 Type APP for QUEUE | Press [ENTER]: ' typed < /dev/tty

if [ "$typed" == "deploy" ]; then question2; fi

if [ "$typed" == "exit" ]; then exit; fi

current=$(cat /var/plexguide/pgbox.buildup | grep "\<$typed\>")
if [ "$current" != "" ]; then queued && question1; fi

current=$(cat /var/plexguide/pgbox.running | grep "\<$typed\>")
if [ "$current" != "" ]; then exists && question1; fi

current=$(cat /var/plexguide/program.temp | grep "\<$typed\>")
if [ "$current" == "" ]; then badinput1 && question1; fi

part1
}

part1 () {
echo "$typed" >> /var/plexguide/pgbox.buildup
num=0

touch /var/plexguide/pgbox.output && rm -rf /var/plexguide/pgbox.output

while read p; do
echo -n $p >> /var/plexguide/pgbox.output
echo -n " " >> /var/plexguide/pgbox.output
if [ "$num" == 7 ]; then
  num=0
  echo " " >> /var/plexguide/pgbox.output
fi
done </var/plexguide/pgbox.buildup

sed -i "/^$typed\b/Id" /var/plexguide/app.list

question1
}

final () {
  read -p '✅ Process Complete! | PRESS [ENTER] ' typed < /dev/tty
  echo
  exit
}

question2 () {

# Image Selector
image=off
while read p; do

echo $p > /tmp/program_var

bash /opt/plexguide/containers/image/_image.sh
done </var/plexguide/pgbox.buildup

# Cron Execution
edition=$( cat /var/plexguide/pg.edition )
if [[ "$edition" == "PG Edition - HD Multi" || "$edition" == "PG Edition - HD Solo" ]]; then a=b
else
  croncount=$(sed -n '$=' /var/plexguide/pgbox.buildup)
  echo "false" > /var/plexguide/cron.count
  if [ "$croncount" -ge "2" ]; then bash /opt/plexguide/menu/cron/mass.sh; fi
fi


while read p; do
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$p - Now Installing!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

sleep 2.5

if [ "$p" == "plex" ]; then bash /opt/plexguide/menu/plex/plex.sh;
elif [ "$p" == "nzbthrottle" ]; then nzbt; fi

# Store Used Program
echo $p > /tmp/program_var
# Execute Main Program
ansible-playbook /opt/plexguide/containers/$p.yml

if [[ "$edition" == "PG Edition - HD Multi" || "$edition" == "PG Edition - HD Solo" ]]; then a=b
else if [ "$croncount" -eq "1" ]; then cronexe; fi; fi

# End Banner
bash /opt/plexguide/menu/endbanner/endbanner.sh >> /tmp/output.info

sleep 2
done </var/plexguide/pgbox.buildup
echo "" >> /tmp/output.info
cat /tmp/output.info
final
}

pinterface () {

boxuser=$(cat /var/plexguide/boxcommunity.user)
boxbranch=$(cat /var/plexguide/boxcommunity.branch)

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Community Box Edition!         📓 Reference: community.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💬 User: $boxuser | Branch: $boxbranch

[1] Change User Name & Branch
[2] Deploy Community Box - Personal (Forked)
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -p 'Type a Selection | Press [ENTER]: ' typed < /dev/tty

case $typed in
    1 )
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬 IMPORTANT MESSAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Username & Branch are both case sensitive! Normal default branch is v8,
but check the branch under your fork that is being pulled!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
        read -p 'Username | Press [ENTER]: ' boxuser < /dev/tty
        read -p 'Branch   | Press [ENTER]: ' boxbranch < /dev/tty
        echo "$boxuser" > /var/plexguide/boxcommunity.user
        echo "$boxbranch" > /var/plexguide/boxcommunity.branch
        pinterface ;;
    2 )
        existcheck=$(git ls-remote --exit-code -h "https://github.com/$boxuser/PlexGuide-Community" | grep "$boxbranch")
        if [ "$existcheck" == "" ]; then echo;
        read -p '💬 Exiting! Forked Version Does Not Exist! | Press [ENTER]: ' typed < /dev/tty
        mainbanner; fi

        boxversion="personal"
        initial
        question1 ;;
    z )
        exit ;;
    Z )
        exit ;;
    * )
        mainbanner ;;
esac
}

mainbanner () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Community Box Edition!         📓 Reference: community.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💬 Community Box apps simplify their usage within PlexGuide! PG provides more
focused support and development based on community usage.

💬 The Personal Forked option will install your version of Community Box. Good
for testing or for personal mod's! Ensure that it exist prior to use!

[1] Utilize Community Box - PlexGuide's
[2] Utilize Community Box - Personal (Forked)
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -p 'Type a Selection | Press [ENTER]: ' typed < /dev/tty

case $typed in
    1 )
        boxversion="official"
        initial
        question1 ;;
    2 )
        variable /var/plexguide/boxcommunity.user "NOT-SET"
        variable /var/plexguide/boxcommunity.branch "NOT-SET"
        pinterface ;;
    z )
        exit ;;
    Z )
        exit ;;
    * )
        mainbanner ;;
esac
}

# FUNCTIONS END ##############################################################
echo "" > /tmp/output.info
mainbanner
