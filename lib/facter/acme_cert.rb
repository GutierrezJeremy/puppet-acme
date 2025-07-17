require 'facter'

Facter.add(:acme_certs) do
  setcode do
    certs = {}

    Dir['/etc/acme.sh/results/*.pem']
      .map { |a| File.basename(a, '.pem') }
      .each do |cert_name|
      crt = File.read("/etc/acme.sh/results/#{cert_name}.pem")
      ca = File.read("/etc/acme.sh/results/#{cert_name}.ca")

      begin
        cert = OpenSSL::X509::Certificate.new(crt)
      rescue OpenSSL::X509::CertificateError => e
        raise Puppet::ParseError, "Not a valid x509 certificate: #{e}"
      end
      cn = cert.subject.to_a.find { |name, _, _| name == 'CN' }[1]

      # disable the ruby3.1+ style of omitting the hash value for a while to keep compatibility
      # rubocop:disable Style/HashSyntax
      certs[cert_name] = {
        crt: crt.strip,
        ca: ca.strip,
        cn: cn,
      }
      # rubocop:enable Style/HashSyntax
    end

    certs
  end
end
