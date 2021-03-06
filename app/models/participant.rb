class Participant < ApplicationRecord
  has_one :questionnaire
  belongs_to :added_by, :class_name => Researcher

  def self.from_params params
    if(params[:participant_id] and params[:install_id])
      participant = Participant.where(
        participant_id: params[:participant_id],
        install_id: params[:install_id]
      ).first_or_create
      params.permit!
      params.each do |field, value|
        if value
          case field
          when 'date_added', 'date_modified', 'questionnaire_started', 'date_consented'
            # this is a javascript date in the form of miliseconds!
            date = Time.at(value.to_i/1000).to_datetime
            participant.send("#{field}=", date)
          when 'responses'
            questionnaire = participant.build_questionnaire
            value.each do |k, v|
              questionnaire.send("#{k}=", v) if(questionnaire.respond_to? k)
            end
          else
            participant.send("#{field}=", value) if(participant.respond_to? field)
          end
        end
      end
      participant
    end
  end

  def to_s
    name = questionnaire.try(:full_name) || first_name
    name = '<no name given>' if name.blank?
    "#{id} #{name}"
  end
end
