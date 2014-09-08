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

######################
# END CONFIGURATION
######################
 
while true

	# Read in emails addresses
	emails_file = File.open("emails.txt", "a+")
	email_addresses = Array.new
	emails_file.each_line do |line|
		email_addresses.push line
	end

	# Check email for new subscriptions
	Mail.defaults do
	  retriever_method :pop3, :address    => "pop.gmail.com",
	                          :port       => 995,
	                          :user_name  => from_email,
	                          :password   => from_email_password,
	                          :enable_ssl => true
	end

	emails = Mail.all
	emails.each do |email|
		# If "SUBSCRIBE" is in the subject, add email to email_addresses array (and file!)
		if email.to_s[/Subject: SUBSCRIBE/]
			# Regex to get the FROM email address
			email_to_add = email.to_s[/.*<([^>]*)/,1]
			# If email has not been added, add it to the list
			if (email_addresses.include? email_to_add) == false
				email_addresses.push email_to_add
	      		emails_file.write "\n#{email_to_add}"
			end
		end
	end

	emails_file.close

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
			email_addresses.each do |email|
	        	smtp.send_message(message, from_email, email)
	        	puts "Email sent to #{email}"
	        end
	        smtp.finish
	        file = File.open("old_source", "w+")
	        file.write(source.inner_html)
	        file.close
	end
	sleep 7200
end
