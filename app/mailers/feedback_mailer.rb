class FeedbackMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def feedback_message(feedback)
    @feedback = feedback
    # contact@vizbu.com
    mail(:to => "contact@vizbu.com", :subject => feedback.subject || "No Subject", :from => feedback.email) 
  end
end
