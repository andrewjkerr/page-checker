require 'net/http'
require 'net/smtp'
require 'nokogiri'
require 'open-uri'

######################
# START CONFIGURATION
######################

# URL of page to check
url_to_check = "http://www.andrewjkerr.com"

# Gmail information
from_email = "email@gmail.com"
from_email_password = "qwerty123adobepassword1"

# Email array; to add an email, just add an extra line
emails = %w[email1@gmail.com
			email2@whatever.com
			email3@yahoo.com]

######################
# END CONFIGURATION
######################
 
while true
	last_updated_source = Nokogiri::HTML(open("old_source.html"))
	source = Nokogiri::HTML(open(url_to_check))

	if last_updated_source.inner_html != source.inner_html
	        smtp = Net::SMTP.new 'smtp.gmail.com', 587
	        smtp.enable_starttls
	        smtp.start('gmail.com', from_email, from_email_password, :login)
message = <<MESSAGE_END
From: Updates <#{from_email}>
To: Update-List <updates@whatever.com>
Subject: Page Updated!
Content-type: text/html
 
#{url_to_check} has changed!

#{source.inner_html}
MESSAGE_END
			emails.each do |email|
	        	smtp.send_message(message, from_email, email)
	        	puts "Email sent to #{email}"
	        end
	        smtp.finish
	        file = File.open("old_source", "w+")
	        file.write(source.inner_html)
	end
	sleep 7200
end
