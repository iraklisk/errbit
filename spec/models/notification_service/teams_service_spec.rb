describe NotificationServices::TeamsService, type: 'model' do
  it "it should send a notification to a user-specified URL" do
    notice = Fabricate :notice
    notification_service = Fabricate :teams_notification_service, app: notice.app
    problem = notice.problem

    payload = notification_service.teams_payload(problem)
    expect(HTTParty).to receive(:post).with(notification_service.api_token, headers: { 'Content-Type' => 'application/json' }, body: payload.to_json).and_return(true)

    notification_service.create_notification(problem)
  end

  context "#teams_payload_for_teams" do
    it "validate structure and data" do
      notice = Fabricate :notice
      notification_service = Fabricate :teams_notification_service, app: notice.app
      problem = notice.problem
      payload_title = notification_service.teams_payload_title(problem)
      payload = notification_service.teams_payload(problem)

      expect(payload['summary']).to eq(payload_title)
      expect(payload['title']).to eq(payload_title)

      sections = payload['sections']
      expect(sections).to be_a(Array)
      expect(sections.length).to eq(1)

      section = sections.first

      expect(section).to be_a(Hash)
      expect(section['activityTitle']).to eq(problem.message)

      facts = section['facts']
      expect(facts).to be_a(Array)
      expect(facts.length).to eq(5)

      facts.each do |fact|
        expect(fact).to be_a(Hash)

        fact_name = fact['name']
        expect(fact_name).to be_a(String)
        expect(fact_name).not_to eq("")
      end

      potential_action = section['potentialAction']
      expect(potential_action).to be_a(Array)
      expect(potential_action.length).to eq(1)

      action = potential_action.first
      expect(action).to be_a(Hash)
      expect(action['@type']).to eq("OpenUri")
      expect(action['name']).to eq("View in Errbit")

      action_targets = action['targets']
      expect(action_targets).to be_a(Array)
      expect(action_targets.length).to eq(1)

      target = action_targets.first
      expect(target).to be_a(Hash)
      expect(target["os"]).to eq("default")
      expect(target["uri"]).to eq(problem.url)
    end
  end
end
