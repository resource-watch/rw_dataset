require 'acceptance_helper'

module V1
  describe 'Clone Datasets', type: :request do
    fixtures :rest_connectors
    fixtures :json_connectors
    fixtures :datasets

    context 'For specific dataset' do
      context 'Rest dataset' do
        let!(:dataset_id) { Dataset.find_by(name: 'cartodb test set').id }

        it 'Allows to clone cartodb dataset' do
          post "/dataset/#{dataset_id}/clone", params: {"loggedUser": {"role": "Manager", "extraUserData": { "apps": ["gfw","wrw"] }, "id": "3242-32442-432"},
                                                        "dataset": {"datasetUrl": "http://ec2-52-23-163-254.compute-1.amazonaws.com/query/4?select[]=iso,population&filter=(iso=='ESP','AUS')&aggrBy[]=iso&aggrFunc=sum&order[]=-iso", "application": ["gfw"] } }

          expect(status).to eq(201)
          expect(json_attr['name']).to                       match('_copy')
          expect(json_attr['provider']).to                   eq('rwjson')
          expect(json_attr['application']).to                eq(['gfw'])
          expect(json_attr['userId']).to                     eq('3242-32442-432')
          expect(json_attr['clonedHost']['hostType']).to     eq('RestConnector')
          expect(json_attr['clonedHost']['hostProvider']).to eq('cartodb')
        end

        it 'Do not allow to clone dataset if user has role user' do
          post "/dataset/#{dataset_id}/clone", params: {"loggedUser": {"role": "user", "extraUserData": { "apps": ["gfw","wrw"] }, "id": "3242-32442-432"},
                                                        "dataset": {"datasetUrl": "http://ec2-52-23-163-254.compute-1.amazonaws.com/query/4?select[]=iso,population&filter=(iso=='ESP','AUS')&aggrBy[]=iso&aggrFunc=sum&order[]=-iso", "application": ["gfw"] } }

          expect(status).to eq(401)
          expect(json_main['errors'][0]['title']).to eq('Not authorized!')
        end

        it 'Do not allow to clone dataset if not in apps' do
          post "/dataset/#{dataset_id}/clone", params: {"loggedUser": {"role": "Manager", "extraUserData": { "apps": ["gfw","wrw"] }, "id": "3242-32442-432"},
                                                        "dataset": {"datasetUrl": "http://ec2-52-23-163-254.compute-1.amazonaws.com/query/4?select[]=iso,population&filter=(iso=='ESP','AUS')&aggrBy[]=iso&aggrFunc=sum&order[]=-iso", "application": ["gfw", "test"] } }

          expect(status).to eq(401)
          expect(json_main['errors'][0]['title']).to eq('Not authorized!')
        end
      end

      context 'Json dataset' do
        let!(:dataset_id) { Dataset.find_by(name: 'Json test set').id }
        let!(:settings)   { ServiceSetting.create(name: 'api-gateway', listener: true, token: '3123123der324eewr434ewr4324', url: 'http://192.168.99.100:8000') }

        it 'Allows to clone json dataset' do
          post "/dataset/#{dataset_id}/clone", params: {"loggedUser": {"role": "admin", "extraUserData": { "apps": ["gfw","wrw"] }, "id": "3242-32442-432"},
                                                        "dataset": {"datasetUrl": "http://192.168.99.100:8000/query/4?select[]=iso,population&filter=(iso=='ESP','AUS')&aggrBy[]=iso&aggrFunc=sum&order[]=-iso", "application": ["gfw"] } }

          expect(status).to eq(201)
          expect(json_attr['name']).to                       match('_copy')
          expect(json_attr['provider']).to                   eq('rwjson')
          expect(json_attr['userId']).to                     eq('3242-32442-432')
          expect(json_attr['application']).to                eq(['gfw'])
          expect(json_attr['clonedHost']['hostType']).to     eq('JsonConnector')
          expect(json_attr['clonedHost']['hostProvider']).to eq('rwjson')
          expect(json_attr['clonedHost']['hostUrl']).to      eq("http://192.168.99.100:8000/query/4?select[]=iso,population&filter=(iso=='ESP','AUS')&aggrBy[]=iso&aggrFunc=sum&order[]=-iso")
        end
      end
    end
  end
end
