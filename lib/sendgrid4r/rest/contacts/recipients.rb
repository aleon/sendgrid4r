# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'sendgrid4r/rest/request'

module SendGrid4r
  module REST
    module Contacts
      #
      # SendGrid Web API v3 Contacts - Recipients
      #
      module Recipients
        include SendGrid4r::REST::Request

        Recipient = Struct.new(
          :created_at,
          :custom_fields,
          :email,
          :first_name,
          :id,
          :last_clicked,
          :last_emailed,
          :last_name,
          :last_opened,
          :updated_at
        )

        Recipients = Struct.new(:recipients)

        def self.create_recipient(resp)
          return resp if resp.nil?
          custom_fields = []
          resp['custom_fields'].each do |field|
            custom_fields.push(
              SendGrid4r::REST::Contacts::CustomFields.create_field(field)
            )
          end
          Recipient.new(
            resp['created_at'],
            custom_fields,
            resp['email'],
            resp['first_name'],
            resp['id'],
            resp['last_clicked'],
            resp['last_emailed'],
            resp['last_name'],
            resp['last_opend'],
            resp['updated_at']
          )
        end

        def self.create_recipients(resp)
          return resp if resp.nil?
          recipients = []
          resp['recipients'].each do |recipient|
            recipients.push(
              SendGrid4r::REST::Contacts::Recipients.create_recipient(recipient)
            )
          end
          Recipients.new(recipients)
        end

        def self.url(recipient_id = nil)
          url = "#{SendGrid4r::Client::BASE_URL}/contactdb/recipients"
          url = "#{url}/#{recipient_id}" unless recipient_id.nil?
          url
        end

        def post_recipient(params, &block)
          resp = post(
            @auth, SendGrid4r::REST::Contacts::Recipients.url, params, &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_recipient(resp)
        end

        def delete_recipients(emails, &block)
          delete(
            @auth, SendGrid4r::REST::Contacts::Recipients.url, emails, &block
          )
        end

        def get_recipients(limit = nil, offset = nil, &block)
          params = {}
          params['limit'] = limit unless limit.nil?
          params['offset'] = offset unless offset.nil?
          resp = get(
            @auth, SendGrid4r::REST::Contacts::Recipients.url, params, &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_recipients(resp)
        end

        def get_recipients_by_id(recipient_ids, &block)
          resp = get(
            @auth,
            "#{SendGrid4r::REST::Contacts::Recipients.url}/batch",
            nil,
            recipient_ids,
            &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_recipients(resp)
        end

        def get_recipients_count(&block)
          resp = get(
            @auth,
            "#{SendGrid4r::REST::Contacts::Recipients.url}/count",
            &block
          )
          resp['recipient_count'] unless resp.nil?
        end

        def search_recipients(params, &block)
          resp = get(
            @auth,
            "#{SendGrid4r::REST::Contacts::Recipients.url}/search",
            params,
            &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_recipients(resp)
        end

        def get_recipient(recipient_id, &block)
          resp = get(
            @auth,
            SendGrid4r::REST::Contacts::Recipients.url(recipient_id),
            &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_recipient(resp)
        end

        def delete_recipient(recipient_id, &block)
          delete(
            @auth,
            SendGrid4r::REST::Contacts::Recipients.url(recipient_id),
            &block
          )
        end

        def get_lists_recipient_belong(recipient_id, &block)
          resp = get(
            @auth,
            "#{SendGrid4r::REST::Contacts::Recipients.url(recipient_id)}/lists",
            &block
          )
          SendGrid4r::REST::Contacts::Lists.create_lists(resp)
        end

        def post_recipients(recipients, &block)
          resp = post(
            @auth,
            "#{SendGrid4r::Client::BASE_URL}/contactdb/recipients_batch",
            recipients,
            &block
          )
          SendGrid4r::REST::Contacts::Recipients.create_result(resp)
        end

        ResultAddMultiple = Struct.new(
          :error_count,
          :error_indices,
          :new_count,
          :persisted_recipients,
          :updated_count
        )

        def self.create_result(resp)
          return resp if resp.nil?
          error_indices = []
          resp['error_indices'].each do |index|
            error_indices.push(index)
          end
          persisted_recipients = []
          resp['persisted_recipients'].each do |value|
            persisted_recipients.push(value)
          end
          ResultAddMultiple.new(
            resp['error_count'],
            error_indices,
            resp['new_count'],
            persisted_recipients,
            resp['updated_count']
          )
        end
      end
    end
  end
end
