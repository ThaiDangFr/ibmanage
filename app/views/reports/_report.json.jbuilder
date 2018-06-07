json.extract! report, :id, :name, :code, :portfolio_id, :created_at, :updated_at
json.url report_url(report, format: :json)
