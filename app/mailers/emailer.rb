#encoding: utf-8

class Emailer < ActionMailer::Base
  default from: "qwb-data@mail.haihuilai.cn"
  default bcc: ['wudi@haihuilai.com']

  def send_custom_file(email, subject, file_content, file_name = 'attach_file', is_compress = false)

    new_file_name = file_name

    if is_compress
      buffer = Zip::OutputStream.write_buffer do |out|
        out.put_next_entry(file_name)
        out.write(file_content)
      end.string

      new_file_name.concat(".zip")
    else
      buffer = file_content
    end

    attachments[new_file_name] = {
      mime_type: "application/octet-stream",
      content: buffer
    }

    mail(:subject => subject, to: email) do |format|
      format.html { render :text => '见附件'}
    end
  end
end
