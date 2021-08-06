# frozen_string_literal: true

require 'studitemps/utils/uri'

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

        it 'for single ID' do
          klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: 'final')
          expect(klass.id).to eq 'final'
        end

        it 'for a list of IDs' do
          klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: %w[final past_due])
          expect(klass.id).to eq %w[final past_due]
        end

        it 'for regex' do
          klass = URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: /I-\d{3}/)
          expect(klass.id).to eq(/I-\d{3}/)
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

        context 'custom regex' do
          subject(:regex) {
            URI.build(schema: 'com.example', context: 'billing', resource: 'invoice', id: /I-\d{3}/)::REGEX
          }

          it { is_expected.to match 'com.example:billing:invoice:I-123' }
          it { is_expected.to_not match 'com.example:billing:invoice:i-123' }
          it { is_expected.to_not match 'com.example:billing:invoice:123' }
          it { is_expected.to_not match 'com.example:billing:invoice:I-abc' }
          it { is_expected.to_not match 'com.example:billing:invoice:I-1234' }
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

        # Extensions require special files. Every extesion is loaded in a special `it` test so that we
        # have not extensions until this point. This requires that we run all tests in order.
        context 'extensions' do
          context 'de/serialization' do
            subject(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
            let(:uri) { klass.new(id: '<id>') }

            before do
              require 'studitemps/utils/uri/extensions/serialization'
            end

            specify '.dump' do
              expect(klass.dump(uri)).to eq 'com.example:billing:invoice:<id>'
            end

            specify '.load' do
              expect(klass.load(nil)).to be_nil
              expect(klass.load('com.example:billing:invoice:<id>')).to eq uri
            end

            specify '#serialize' do
              expect(uri.serialize).to eq 'com.example:billing:invoice:<id>'
            end
          end

          context 'base64 encoding' do
            subject(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }
            let(:uri) { klass.new(id: '<id>') }

            let(:encoded_uri) { 'Y29tLmV4YW1wbGU6YmlsbGluZzppbnZvaWNlOjxpZD4=' }

            before do
              require 'studitemps/utils/uri/extensions/base64'
            end

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

            before do
              require 'studitemps/utils/uri/extensions/aliases'
            end

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

            before do
              require 'studitemps/utils/uri/extensions/string_equality'
            end

            it { is_expected.to eq 'com.example:billing:invoice:<id>' }
            it { is_expected.to eql 'com.example:billing:invoice:<id>' }
          end

          context 'types' do
            let(:uri) { klass.new(id: '<id>') }
            let(:klass) { URI.build(schema: 'com.example', context: 'billing', resource: 'invoice') }

            before do
              require 'studitemps/utils/uri/extensions/types'
            end

            describe 'Types Module' do
              let(:uri_type) { klass::Types::URI }
              let(:string_type) { klass::Types::String }

              it 'URI' do
                expect(uri_type[uri]).to eq uri
                expect(uri_type['com.example:billing:invoice:<id>']).to eq uri
                expect {
                  uri_type['something']
                }.to raise_error Dry::Types::CoercionError
              end

              it 'String' do
                expect(string_type[uri]).to eq uri.to_s
                expect(string_type['com.example:billing:invoice:<id>']).to eq uri.to_s
                expect {
                  string_type['something']
                }.to raise_error Dry::Types::CoercionError
              end

              describe 'sum types' do
                let(:invoice_klass) { URI.build(from: klass, resource: 'invoice') }
                let(:invoice_duplicate_klass) { URI.build(from: klass, resource: 'invoice_duplicate') }

                let(:invoice_uri) { invoice_klass.new(id: 'R42') }
                let(:invoice_duplicate_uri) { invoice_duplicate_klass.new(id: 'RD42') }

                it 'URI' do
                  sum_type = invoice_klass::Types::URI | invoice_duplicate_klass::Types::URI
                  expect(sum_type[invoice_uri]).to eq invoice_uri
                  expect(sum_type[invoice_duplicate_uri]).to eq invoice_duplicate_uri
                  expect(sum_type[invoice_uri.to_s]).to eq invoice_uri
                  expect(sum_type[invoice_duplicate_uri.to_s]).to eq invoice_duplicate_uri
                  expect {
                    sum_type['com.example:billing:bill:B23']
                  }.to raise_error Dry::Types::CoercionError
                end

                it 'String' do
                  sum_type = invoice_klass::Types::String | invoice_duplicate_klass::Types::String
                  expect(sum_type[invoice_uri]).to eq invoice_uri.to_s
                  expect(sum_type[invoice_duplicate_uri]).to eq invoice_duplicate_uri.to_s
                  expect(sum_type[invoice_uri.to_s]).to eq invoice_uri.to_s
                  expect(sum_type[invoice_duplicate_uri.to_s]).to eq invoice_duplicate_uri.to_s
                  expect {
                    sum_type['com.example:billing:bill:B23']
                  }.to raise_error Dry::Types::CoercionError
                end
              end

            end

            describe 'Fixed URI' do
              subject(:klass) {
                URI.build(
                  schema: 'com.example',
                  context: 'billing',
                  resource: 'invoice',
                  id: 'final'
                )
              }

              it 'only accepts fixed URI' do
                uri = klass.new(
                  schema: 'com.example',
                  context: 'billing',
                  resource: 'invoice',
                  id: 'final'
                )

                expect(klass.new(id: 'final')).to eq uri

                expect {
                  klass.new(id: 'not_final')
                }.to raise_error Dry::Types::ConstraintError

                expect {
                  klass.new(resource: 'not_invoice', id: 'final')
                }.to raise_error Dry::Types::ConstraintError

                expect {
                  klass.new(context: 'not_billing', id: 'final')
                }.to raise_error Dry::Types::ConstraintError

                expect {
                  klass.new(schema: 'not_example.com', id: 'final')
                }.to raise_error Dry::Types::ConstraintError
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

            describe 'Regexp' do
              let(:invoice_klass) { URI.build(from: klass, resource: 'invoice', id: /I-\d{3}/) }

              it 'validates input' do
                expect {
                  invoice_klass.new(id: 'I-123')
                }.to_not raise_error

                expect {
                  invoice_klass.new(id: 'X-123')
                }.to raise_error Dry::Types::ConstraintError
              end

              it 'has uri type' do
                type = invoice_klass::Types::URI
                uri = invoice_klass.new(id: 'I-123')

                expect(type[uri]).to eq uri
                expect(type['com.example:billing:invoice:I-123']).to eq uri
                expect {
                  type['com.example:billing:invoice:<other>']
                }.to raise_error Dry::Types::CoercionError
              end

              it 'has string type' do
                type = invoice_klass::Types::String
                uri = invoice_klass.new(id: 'I-123')

                expect(type[uri]).to eq uri.to_s
                expect(type['com.example:billing:invoice:I-123']).to eq uri.to_s
                expect {
                  type['com.example:billing:invoice:<other>']
                }.to raise_error Dry::Types::CoercionError
              end
            end
          end
        end
      end
    end
  end
end


