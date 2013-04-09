echo 'sending email....'
curl -s --user api:key-9idzlk7lypeeckbs4ard8opj9inba6-6 \
  https://api.mailgun.net/v2/audioskim.mailgun.org/messages \
  -F from='Test User <yeskela@gmail.com>' \
  -F to=localtunnel@audioskim.mailgun.org \
  -F subject='Test messsage with attachment' \
  -F text='Testing some Mailgun awesomness!' \
  -F attachment=@voicemail-sample.mp3
