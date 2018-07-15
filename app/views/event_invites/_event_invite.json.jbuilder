json.extract! event_invite, :id, :role, :status, :sender_id, :event_id, :recipient_id, :created_at, :updated_at
json.url event_invite_url(event_invite, format: :json)
