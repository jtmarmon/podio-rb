class Podio::SpaceInvite < ActivePodio::Base
  property :space_id, :integer
  property :role, :string
  property :subject, :string
  property :message, :string
  property :notify, :boolean
  property :users, :array
  property :mails, :array
  property :profiles, :array
  property :activation_code, :integer

  def save
    self.class.create(self.space_id, self.role, self.attributes.except(:contacts))
  end

  def accept(invite_code)
    self.class.accept(invite_code)
  end
  
  handle_api_errors_for :save, :accept # Call must be made after the methods to handle have been defined
  
  class << self
    def create(space_id, role, attributes={})
      response = Podio.connection.post do |req|
        req.url "/space/#{space_id}/invite"
        req.body = attributes.merge(:role => role)
      end

      response.body
    end

    def accept(invite_code)
      response = Podio.connection.post do |req|
        req.url '/space/invite/accept'
        req.body = {:invite_code => invite_code}
      end

      response.body
    end

    def decline(invite_code)
      response = Podio.connection.post do |req|
        req.url '/space/invite/decline'
        req.body = {:invite_code => invite_code}
      end

      response.body
    end

    def find(invite_code)
      member Podio.connection.get("/space/invite/status?invite_code=#{ERB::Util.url_encode(invite_code)}").body
    end
    
  end
end