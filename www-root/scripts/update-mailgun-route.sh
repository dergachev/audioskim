echo "Not implemented"
exit

# see https://mailgun.net/cp/routes?domain=audioskim.mailgun.org#
# see http://documentation.mailgun.net/user_manual.html#api-routing-samples
curl -s --user api:key-9idzlk7lypeeckbs4ard8opj9inba6-6 \
    https://api.mailgun.net/v2/routes/1 \
    -X PUT \
    -F action='forward("http://123.localtunnel.com/process_email/")'\
    -F action='stop()'
