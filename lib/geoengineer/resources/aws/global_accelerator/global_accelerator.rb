class GeoEngineer::Resources::GlobalAccelerator < GeoEngineer::Resource
  validate -> { validate_required_attributes([:name, :ip_address_type, :enabled]) }

  after :initialize, -> { _terraform_id -> { NullObject.maybe(remote_resource)._terraform_id } }

  def to_terraform_state
    tfstate = super
    tfstate[:primary][:attributes] = {
      'name' => name,
      'ip_address_type' => (ip_address_type || "IPV4"),
      'enabled' => (enabled || true)
    }

    tfstate[:primary][:attributes]['filename'] = filename if filename

    tfstate
  end

  def short_type
    "ga"
  end

  def support_tags?
    false
  end

  def self._fetch_remote_resources(provider)
    client = AwsClients.accelerator(provider)
    client.describe_accelerator['accelerator'].map(&:to_h).map do |ga|
      ga[:_terraform_id] = ga[:accelerator_arn]
      ga[:_geo_id] = "#{ga[:accelerator_arn]}::#{ga[:type]}"
      ga[:_arn] = ga[:accelerator_arn]
      ga
    end
  end
end
