# frozen_string_literal: true
module ParamsHandler
  extend ActiveSupport::Concern

  included do
    def dataset_params_sanitizer
      params.require(:dataset).except(:name, :format, :data_path, :attributes_path, :status, :application,
                                      :layer_info, :data_overwrite, :subtitle, :vocabularies, :tags, :topics, :provider, :legend)
                              .merge(logged_user: params[:logged_user],
                                     connector_provider: params[:dataset].dig(:provider),
                                     dataset_attributes: { name: params[:dataset].dig(:name),
                                                           legend: params[:dataset].dig(:legend),
                                                           format: params[:dataset].dig(:format),
                                                           data_path: params[:dataset].dig(:data_path),
                                                           attributes_path: params[:dataset].dig(:attributes_path),
                                                           status: params[:dataset].dig(:status),
                                                           application: params[:dataset].dig(:application),
                                                           layer_info: params[:dataset].dig(:layer_info),
                                                           data_overwrite: params[:dataset].dig(:data_overwrite),
                                                           subtitle: params[:dataset].dig(:subtitle),
                                                           vocabularies: params[:dataset].dig(:vocabularies),
                                                           tags: params[:dataset].dig(:tags) }.reject{ |_, v| v.nil? })
                              .permit!
                              .reject{ |_, v| v.nil? }
    end

    private

      def dataset_params
        dataset_params_sanitizer.except(:user_id).tap do |create_params|
          create_params[:dataset_attributes][:user_id] = params.dig(:logged_user, :id)
        end
      end

      def dataset_params_for_update
        if @json_connector
          dataset_params_sanitizer.except(:data, :data_attributes, :logged_user, :connector_url, :user_id).tap do |update_params|
            update_params[:dataset_attributes][:user_id] = params[:dataset][:user_id] if params[:dataset][:user_id].present? && params[:logged_user][:role] == 'superadmin'
          end
        elsif @doc_connector
          dataset_params_sanitizer.except(:point, :polygon, :logged_user, :user_id).tap do |update_params|
            update_params[:dataset_attributes][:user_id] = params[:dataset][:user_id] if params[:dataset][:user_id].present? && params[:logged_user][:role] == 'superadmin'
          end
        else
          dataset_params_sanitizer.except(:data, :data_attributes, :logged_user, :user_id).tap do |update_params|
            update_params[:dataset_attributes][:user_id] = params[:dataset][:user_id] if params[:dataset][:user_id].present? && params[:logged_user][:role] == 'superadmin'
          end
        end
      end
  end

  class_methods {}
end
