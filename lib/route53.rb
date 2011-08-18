require 'rubygems' if Gem.nil?
require 'hmac'
require 'hmac-sha2'
require 'base64'
require 'time'
require 'net/http'
require 'net/https'
require 'uri'
require 'hpricot'
require 'builder'
require 'digest/md5'

module Route53
    require 'route53/connection'
    require 'route53/awsresponse'
    require 'route53/zone'
    require 'route53/dnsrecord'
end

$messages = { "InvalidClientTokenId" => "You may have a missing or incorrect secret or access key. Please double check your configuration files and amazon account",
    "MissingAuthenticationToken" => "You may have a missing or incorrect secret or access key. Please double check your configuration files and amazon account",
    "OptInRequired" => "In order to use Amazon's Route 53 service you first need to signup for it. Please see http://aws.amazon.com/route53/ for your account information and use the associated access key and secret.",
    "Other" => "It looks like you've run into an unhandled error. Please send a detailed bug report with the entire input and output from the program to support@50projects.com or to https://github.com/pcorliss/ruby_route_53/issues and we'll do out best to help you.",
    "SignatureDoesNotMatch" => "It looks like your secret key is incorrect or no longer valid. Please check your amazon account information for the proper key.",
    "HostedZoneNotEmpty" => "You'll need to first delete the contents of this zone. You can do so using the '--remove' option as part of the command line interface.",
    "InvalidChangeBatch" => "You may have tried to delete a NS or SOA record. This error is safe to ignore if you're just trying to delete all records as part of a zone prior to deleting the zone. Or you may have tried to create a record that already exists. Otherwise please file a bug by sending a detailed bug report with the entire input and output from the program to support@50projects.com or to https://github.com/pcorliss/ruby_route_53/issues and we'll do out best to help you.",
    "ValidationError" => "Check over your input again to make sure the record to be created is valid. The error message should give you some hints on what went wrong. If you're still having problems please file a bug by sending a detailed bug report with the entire input and output from the program to support@50projects.com or to https://github.com/pcorliss/ruby_route_53/issues and we'll do out best to help you."}
