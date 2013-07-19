# Needs https://code.google.com/p/wkhtmltopdf/downloads/detail?name=wkhtmltoimage-0.11.0_rc1-static-amd64.tar.bz2&can=2&q=
#
require "base64"


class IrcMachine::Plugin::Awards < IrcMachine::Plugin::Base
  CONFIG_FILE = "awards.json"
  CSS = File.expand_path("../awards/style.css", __FILE__)

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? award (\S+) for (.*)$/
      which_wkhtmltoimage = `which wkthmltoimage`
      if $?.exitstatus != 0
        session.msg $1, "I can't generate images D:"
      else
        catch(:processfailed) do
          session.msg $1, generate_award_url($2, $3)
          return
        end
        session.msg $1, "I can't generate images D:"
      end
    end
  end

  def generate_award_url(name, reason)
    html = get_award_html(name, reason)
    image = get_image_content(html)
    resp = upload_image(image)
    return resp["data"]["link"]
  end

  def get_award_html(name, reason)
    uri = URI("http://thousandsunder90.com/form.php")
    response = Net::HTTP.post_form(uri, {
      "yourName" => name,
      "yourSkill" => reason,
      "q_submit" => "Award Me"
    })
    return response.body
  end

  def get_image_content(html)
    begin
      dir = Dir.mktmpdir
      infile = File.join(dir, "in.html")
      outfile = File.join(dir, "out.png")
      css = File.join(dir, "style.css")
      File.open(infile, 'w') do |f|
        f.write(html)
      end
      FileUtils.cp(CSS, css)
      `wkhtmltoimage #{infile} #{outfile}`
      throw(:processfailed) unless $?.exitstatus == 0
      return File.read(outfile)
    ensure
      FileUtils.rm_rf(dir)
    end
  end

  def upload_image(content)
    enc   = Base64.encode64(content)
    uri = URI("https://api.imgur.com/3/image")

    form = URI.encode_www_form({"image" => enc})
    headers = {"Authorization" => "Client-ID #{settings["client_id"]}"}

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.post(uri.request_uri, form, headers)
    end

    return JSON.parse(res.body)
  end

end
