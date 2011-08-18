module Route53
    class AWSResponse
        attr_reader :raw_data

        #I wanted to put this in a seprate file but ruby's method of determinign the root of the gem is a pain in the butt and I was in a hurry. Sorry. -PC


        def initialize(resp,conn)
            @raw_data = unescape(resp)
            if error?
                $stderr.puts "ERROR: Amazon returned an error for the request."
                $stderr.puts "ERROR: RAW_XML: "+@raw_data
                $stderr.puts "ERROR: "+error_message
                $stderr.puts ""
                $stderr.puts "What now? "+helpful_message
                #exit 1
            end
            @conn = conn
            @created = Time.now
            puts "Raw: #{@raw_data}" if @conn.verbose
        end

        def error?
            return Hpricot::XML(@raw_data).search("ErrorResponse").size > 0
        end

        def error_message
            xml = Hpricot::XML(@raw_data)
            msg_code = xml.search("Code")
            msg_text = xml.search("Message")
            return (msg_code.size > 0 ? msg_code.first.inner_text : "") + (msg_text.size > 0 ? ': ' + msg_text.first.innerText : "")
        end

        def helpful_message
            xml = Hpricot::XML(@raw_data)
            msg_code = xml.search("Code").first.innerText
            return $messages[msg_code] if $messages[msg_code]
            return $messages["Other"]
        end

        def complete?
            return true if error?
            if @change_url.nil?
                change = Hpricot::XML(@raw_data).search("ChangeInfo")
                if change.size > 0
                    @change_url = change.first.search("Id").first.innerText
                else
                    return false
                end
            end
            if @complete.nil? || @complete == false
                status = Hpricot::XML(@conn.request(@conn.base_url+@change_url).raw_data).search("Status")
                @complete = status.size > 0 && status.first.innerText == "INSYNC" ? true : false
                if !@complete && @created - Time.now > 60
                    $stderr.puts "WARNING: Amazon Route53 Change timed out on Sync. This may not be an issue as it may just be Amazon being assy. Then again your request may not have completed.'"
                    @complete = true
                end
            end
            return @complete
        end

        def pending?
            #Return opposite of complete via XOR
            return complete? ^ true
        end

        def to_s
            return @raw_data
        end

        def unescape(string)
            string.gsub(/\\0(\d{2})/) { $1.oct.chr }
        end
    end
end
