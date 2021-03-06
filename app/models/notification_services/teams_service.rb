# coding: utf-8
class NotificationServices::TeamsService < NotificationService
  LABEL = "teams"
  FIELDS = [
    [:api_token, {
       placeholder: 'URL to receive a POST request when an error occurs',
       label:       'URL'
     }]
  ]

  def check_params
    if FIELDS.detect { |f| self[f[0]].blank? }
      errors.add :base, 'You must specify the URL'
    end
  end

  def create_notification(problem)
    HTTParty.post(api_token, headers: { 'Content-Type' => 'application/json' }, body: teams_payload(problem).to_json)
  end


  def teams_payload(problem)
    {
      "summary" => teams_payload_title(problem),
      "themeColor" => "0078D7",
      "title" => teams_payload_title(problem),
      "sections" => [
        {
          "activityTitle" => problem.message,
          "facts" => teams_payload_facts(problem)
        }
      ],
      "potentialAction" => teams_payload_actions(problem)
    }
  end

  def teams_payload_title(problem)
    error_title = problem.error_class || problem.message
    "[#{problem.app.name}] #{error_title}"
  end

  private
  def teams_payload_facts(problem)
    [
      fact("Application:", problem.app.name),
      fact("Environment:", problem.environment),
      fact("Where:", problem.where),
      fact("Times Occurred:", problem.notices_count.try(:to_s)),
      fact(
        "First Noticed:",
        problem.first_notice_at.try(:localtime).try(:to_s, :db)
      )
    ]
  end

  def fact(name, value)
    {
      "name" => name,
      "value" => value
    }
  end

  def teams_payload_actions(problem)
    [
      {
        "@type" => "OpenUri",
        "name" => "View in Errbit",
        "targets" => [
          {
            "os" => "default",
            "uri" => problem.url
          }
        ]
      }
    ]
  end
end
