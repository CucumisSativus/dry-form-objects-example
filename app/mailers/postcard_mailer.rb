class PostcardMailer < ApplicationMailer
  def send_postcard(to_email:, postcard:)
    @postcard = postcard
    mail(to: to_email, subject: 'super postcard')
  end
end
