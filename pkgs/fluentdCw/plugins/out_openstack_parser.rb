require "fluent/output"

module Cloudwatt
  class OpenStackParserOutput < ::Fluent::Output

    ::Fluent::Plugin.register_output("openstack_parser", self)

    def configure(conf)
      super
      @pids = {}
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        record["level"] = record.delete("levelname").downcase

        process_id = record.delete("process").to_i
        record["process_id"] = process_id
        record["process_name"] = @pids[process_id] || (@pids[process_id] = File.read("/proc/#{process_id}/comm").strip rescue nil)

        record["sourcecode"] = {
          "function" => record.delete("funcname"),
          "line" => record.delete("lineno").to_i,
          "path" => record.delete("pathname")
        }

        record["message"].strip!

        ::Fluent::Engine.emit "openstack.message", time, record
      end

      chain.next
    end

  end
end
