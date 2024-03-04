helm install -f values/redis-values.yaml rediscart charts/redis

helm install -f values/email-service-values.yaml emailservice charts/microservice
helm install -f values/cartservice-service-values.yaml chartservice charts/microservice
helm install -f values/currencyservice-service-values.yaml currencyservice charts/microservice
helm install -f values/paymentservice-service-values.yaml paymentservice charts/microservice
helm install -f values/recommendation-service-values.yaml recommendationservice charts/microservice
helm install -f values/productcatalog-service-values.yaml productcatalogservice charts/microservice
helm install -f values/shippingservice-service-values.yaml shippingserviceservice charts/microservice
helm install -f values/adservice-service-values.yaml adserviceservice charts/microservice
helm install -f values/checkoutservice-service-values.yaml checkoutservice charts/microservice
helm install -f values/frontend-service-values.yaml frontendservice charts/microservice