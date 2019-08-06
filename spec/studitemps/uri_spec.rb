# frozen_string_literal: true

require 'studitemps/utils/uri'

require 'studitemps/utils/uri/extensions/serialization'
require 'studitemps/utils/uri/extensions/base64'
require 'studitemps/utils/uri/extensions/aliases'
require 'studitemps/utils/uri/extensions/string_equality'

module Studitemps
  module Utils # rubocop:disable Metrics/ModuleLength
    RSpec.describe URI do

      describe 'create new URI classes' do

        it 'only with schema' do
          klass = URI.build(schema: 'com.example')
          expect(klass.schema).to eq 'com.example'
        end

        it 'for a given context' do
          klass = URI.build(schema: 'com.example', context: 'billing')
          expect(klass.schema).to eq 'com.example'
          expect(klass.context).to eq 'billing'
        end

        it 'for a given resource' do
          klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice')
          expect(klass.schema).to eq 'com.example'
          expect(klass.context).to eq 'billing'
          expect(klass.resource).to eq 'invoice'
        end

        it 'inherits from another uri object' do
          some_klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice')
          klass = URI.build(resource: 'order', from: some_klass)
          expect(klass.schema).to eq 'com.example'
          expect(klass.context).to eq 'billing'
          expect(klass.resource).to eq 'order'
        end

        it 'for a list of IDs' do
          klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: %w[final past_due])
          expect(klass.id).to eq %w[final past_due]
        end
      end

      describe 'URI regex' do
        subject(:regex) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice')::REGEX }

        context 'matched' do
          it { is_expected.to match 'com.example:billing' }
          it { is_expected.to match 'com.example:billing:invoice' }
          it { is_expected.to match 'com.example:billing:invoice:<some_id>' }
        end

        context 'not matched' do
          it { is_expected.to_not match 'com.example' }
          it { is_expected.to_not match 'com.example:some_context' }
          it { is_expected.to_not match 'com.example:invoice' }
          it { is_expected.to_not match 'com.example:billing:<some_id>' }
        end

        context 'specific resources' do
          subject(:regex) {
            URI.build(schema: 'com.example', context: 'billing', resource: %w[invoice invoice_duplicate])::REGEX
          }

          it { is_expected.to match 'com.example:billing:invoice:final' }
          it { is_expected.to_not match 'com.example:billing:bill:final' }
        end

        context 'specific IDs' do
          subject(:regex) {
            URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: %w[final past_due])::REGEX
          }

          it { is_expected.to match 'com.example:billing:invoice:final' }
          it { is_expected.to_not match 'com.example:billing:invoice:pro_forma' }
        end
      end

      describe 'URI instance' do
        context 'instance methods' do
          subject(:uri) { klass.new(id: '<id>') }
          let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }

          specify '#to_s' do
            expect(uri.to_s).to eq 'com.example:billing:invoice:<id>'
          end

          specify '#schema' do
            expect(uri.schema).to eq 'com.example'
          end

          specify '#context' do
            expect(uri.context).to eq 'billing'
          end

          specify '#resource' do
            expect(uri.resource).to eq 'invoice'
          end

          specify '#id' do
            expect(uri.id).to eq '<id>'
          end
        end

        context 'equality' do
          subject(:uri) { klass.new(id: '<id>') }

          let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
          let(:another_resource) { URI.build(from: klass, resource: 'order') }
          let(:another_context) { URI.build(from: klass, context: 'payroll') }
          let(:another_schema) { URI.build(from: klass, schema: 'test.example') }

          it { is_expected.to eq klass.new(id: '<id>') }
          it { is_expected.to_not eq klass.new(id: '<other_id>') }
          it { is_expected.to_not eq another_resource.new(id: '<id>') }
          it { is_expected.to_not eq another_context.new(id: '<id>') }
          it { is_expected.to_not eq another_schema.new(id: '<id>') }

          it 'does not matter if `id` is a string or int' do
            expect(klass.new(id: '42')).to eq klass.new(id: 42)
          end
        end

        context 'class methods' do
          context '.build' do
            subject(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
            let(:uri) { klass.new(id: '<id>') }

            context 'from URI' do
              it 'same URI' do
                new_uri = klass.build(uri)
                expect(new_uri).to eq uri
              end

              it 'from base uri' do
                base_klass = URI.build(schema: 'com.example')
                base_uri = base_klass.build(context: 'billing', resource: 'invoice', id: '<id>')

                new_uri = klass.build(base_uri)
                expect(new_uri).to eq uri
              end

              it 'from special uri' do
                base_klass = URI.build(schema: 'com.example')
                base_uri = base_klass.build(context: 'billing', resource: 'invoice', id: '<id>')

                new_uri = base_klass.build(uri)
                expect(new_uri).to eq base_uri
              end
            end

            it 'from Hash' do
              new_uri = klass.build(id: '<id>')
              expect(new_uri).to eq uri
            end

            context 'from string' do

              it 'succesful' do
                new_uri = klass.build('com.example:billing:invoice:<id>')
                expect(new_uri).to eq uri
              end

              it 'with error' do
                expect {
                  klass.build('com.example:payrol:invoice:<id>')
                }.to raise_error Studitemps::Utils::URI::Base::InvalidURI
              end
            end

            it 'invalid uri' do
              expect {
                klass.build(42)
              }.to raise_error Studitemps::Utils::URI::Base::InvalidURI
            end
          end
        end

        context 'features' do
          context 'de/serialization' do
            subject(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
            let(:uri) { klass.new(id: '<id>') }

            specify '.dump' do
              expect(klass.dump(uri)).to eq 'com.example:billing:invoice:<id>'
            end

            specify '.load' do
              expect(klass.load(nil)).to be_nil
              expect(klass.load('com.example:billing:invoice:<id>')).to eq uri
            end
          end

          context 'base64 encoding' do
            subject(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
            let(:uri) { klass.new(id: '<id>') }

            let(:encoded_uri) { 'Y29tLmV4YW1wbGU6YmlsbGluZzppbnZvaWNlOjxpZD4=' }

            specify '#base64' do
              expect(uri.to_base64).to eq encoded_uri
            end

            specify '.from_base64' do
              expect(klass.from_base64(encoded_uri)).to eq uri
            end
          end

          context 'aliased methods' do
            subject(:uri) { klass.new(id: '<id>') }
            let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }

            specify '#resource_type' do
              expect(uri.resource_type).to eq 'invoice'
            end

            specify '#resource_id' do
              expect(uri.resource_id).to eq '<id>'
            end
          end

          context 'string equality' do
            subject(:uri) { klass.new(id: '<id>') }
            let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }

            it { is_expected.to eq 'com.example:billing:invoice:<id>' }
            it { is_expected.to eql 'com.example:billing:invoice:<id>' }
          end

          context 'types' do
            require 'studitemps/utils/uri/extensions/types'

            let(:uri) { klass.new(id: '<id>') }
            let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }

            describe 'Types Module' do
              let(:uri_type) { klass::Types::URI }
              let(:string_type) { klass::Types::String }

              it 'URI' do
                expect(uri_type[uri]).to eq uri
                expect(uri_type['com.example:billing:invoice:<id>']).to eq uri
                expect {
                  uri_type['something']
                }.to raise_error ::Studitemps::Utils::URI::Base::InvalidURI
              end

              it 'String' do
                expect(string_type[uri]).to eq uri.to_s
                expect(string_type['com.example:billing:invoice:<id>']).to eq uri.to_s
                expect {
                  string_type['something']
                }.to raise_error ::Studitemps::Utils::URI::Base::InvalidURI
              end
            end

            describe 'Attribute Types' do
              subject(:klass) {
                URI.build(
                  schema: 'com.example',
                  context: 'billing',
                  resource: resources,
                  id: ids
                )
              }
              let(:uri) { klass.build('com.example:billing:invoice:final') }
              let(:ids) { %w[final past_due] }
              let(:resources) { %w[invoice invoice_duplicate] }

              specify 'schema:' do
                expect(klass.new(schema: 'com.example', id: 'final')).to eq uri
                expect {
                  klass.new(schema: 'com.examplee', id: 'final')
                }.to raise_error Dry::Types::ConstraintError
              end

              specify 'context:' do
                expect(klass.new(context: 'billing', id: 'final')).to eq uri
                expect {
                  klass.new(context: 'billingg', id: 'final')
                }.to raise_error Dry::Types::ConstraintError
              end

              specify 'resource:' do
                expect(klass.new(resource: 'invoice', id: 'final')).to eq uri
                expect {
                  klass.new(resource: 'bill', id: 'final')
                }.to raise_error Dry::Types::ConstraintError
              end

              specify 'id:' do
                expect(klass.new(id: 'final')).to eq uri
                expect {
                  klass.new(id: 'pro_forma')
                }.to raise_error Dry::Types::ConstraintError
              end
            end
          end
        end
      end
    end
  end
end


