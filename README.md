# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

### Momo-store: [aymomo.ru](https://aymomo.ru)
### Grafana: [grafana.aymomo.ru](https://grafana.aymomo.ru) (login-check/password-check)

## Репозиторий
Репозиторий содержит код, который позволяет развернуть в облаке Yandex Cloude проект "momo-store"

```
momo-store
 |- backend        
 |- frontend       
 |- infrastructure
     |- helm       
        |- momo-store
        |- grafana
        |- prometheus
     |- kubernetes
        |- backend
        |- frontend
     |- terraform
        |- momo-images
 |- screenshots
```

## Описание
1) Директория backend содержит исходный код бэкэнда на языке Go, Dockerfile для контейниризации приложения, файл backend_build.yml, в котором описаны этапы CI/CD процессов;
2) Директория frontend содержит исходный код фронтенда на языке nodejs, Dockerfile для контейниризации приложения, файл frontend_build.yml, в котором описаны этапы CI/CD процессов;
3) Директория infrastructure/terraform содержит файлы конфигурации для развертывания инфраструктуры в Yandex Cloud. Также содержит директория momo-images, содержащая картинки, которые будут загружаться в новый бакет Yandex Object Storage;
4) Директория infrastructure/kubernetes содержит kubernetes-манифесты для публикации приложения (frontend и backend) в кластере K8s;
5) Директория infrastructure/helm содержит helm чарты для приложения momo-store, grafana, prometheus;
6) Директория screenshots содержит скриншоты из браузера, сделанные после завершения работы. 

## Разворачивание инфраструктуры в облаке Yandexс Cloude с помощью terraform
1) Создать сервисный аккаунт с ролью editor
2) Получить статический ключ доступа (access_key и secret_key)
3) Создать бакет с ограниченным доступом для хранения состояния terraform - momo-store-terraform-s3-state
4) Описать backend "s3" конфигурацию в файле s3.tf
5) Присвоить значения переменным в файле variables.tf
6) provider.tf - конфигурация провайдера
7) main.tf - основная конфигурация. Создание ресурсов в Yandex Cloud (Network, Service account config, k8s Cluster with 2 nodes, Security, Public static IP,  DNS zone with records, Static key for sa, New bucket for momo images, Momo images)
6) Последовательно выполнить команды:
```
cd infrastructure/terraform/
terraform init
terraform plan
terraform apply
```
* Файл .terraformrc находится в корневой папке ВМ
### Object Storage
Проверить, что состояние terraform сохраняется в созданном ранее бакете в Yandex Object Storage.
Проверить, что картинки, находящаяся в директории momo-images, успешно загружены в новый бакет, описанный в main.tf.

### K8s cluster
1) yc managed-kubernetes cluster get-credentials k8s-cluster --external - для сохранения текущей конфигурации kubernetes кластера в ~/.kube/config.
2) Создание статического файла конфигурации для использования в процессе CI/CD по инструкции - https://cloud.yandex.ru/ru/docs/managed-kubernetes/operations/connect/create-static-conf

### Настройка единой точки входа трафика в кластер Kubernetes
Установка Ingress-контроллера NGINX
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```
Узнать внешний ip-адрес ingress-контроллера (EXTERNAL-IP)
```
kubectl get svc
```
В сервисе Cloud DNS в соответсвующей зоне установить данный ip address для записей типа А (aymomo.ru., grafana.aymomo.ru., prometheus.aymomo.ru).

### Установка сертификата
Установите менеджер сертификатов
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml

```

### Доменное имя
Зарегистрировать домен для приложения. Создать поддомены для grafana, prometheus.
Указать адреса серверов имен Yandex Cloud в DNS-записях вашего регистратора:
- ns1.yandexcloud.net
- ns2.yandexcloud.net

## Публикация приложения
Публиковать приложение можно двумя способами:
1) Использовать Kubernetes-манифесты, выполнив команды
```
cd infrastructure/kubernetes/
kubectl apply -f backend/
kubectl apply -f frontend/
```
2) Использовать практику CI/CD

## Автоматический процесс CI/CD
В корневой директории проекта находится файл .gitlab-ci.yml, который отслеживает изменения в директориях backend и frontend. В случае изменения запускает процесс CI/CD, описанный в файлах /backend/backend_build.yml и /frontend/frontend_build.yml.
Процесс CI/CD состоит из следующих этапов:
1) build - упаковка приложения в Docker-образ (используется мультистейдж Dockerfile). Полученный образ версионируется и помещается в Gitlab Container Registry;
2) test - тестирование;
3) release - состоит из 2х джоб:
    - Если тесты пройдены удачно, то полученный на уровне build образ версионируется c тэгом "latest" и помещается Gitlab Container Registry
    - Формируется helm-чарт, который загружается в helm-репозиторий Nexus
5) notify - если коммит содержит "send notification", то происходит отправка уведомления в telegram о выпуске нового helm чарта;
6) Выполняется установка(обновление) приложения, используя новый helm-чарта. 


## Мониторинг
Для отслеживания состояния приложения установлены Prometheus, Grafana и Loki.
### Установка Prometheuse
```
cd infrastructure/helm/
helm upgrade --install --atomic prometheus helm/prometheus
```

### Установка Grafana
```
cd infrastructure/helm/
helm upgrade --install --atomic grafana helm/grafana
```

### Установка Loki
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --atomic loki grafana/loki-stack
```
### Конфигурация в Grafana
- Настроить необходимые data sources (prometheus, loki)
- Настройка dashboard/panels на основе data source и определенных метрик
- Проверить наличие логов (loki)

## Пример работы

Momo-store: [aymomo.ru](https://aymomo.ru)

Prometheus: [prometheus.aymomo.ru](https://prometheus.aymomo.ru)

Grafana: [grafana.aymomo.ru](https://grafana.aymomo.ru) (login-check/password-check)



____________________________________________________________________________________________________________________________________________________
#### * Для запуска приложения локально:
Frontend:
```bash
cd frontend/
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```
Backend:
```bash
cd backend/
go run ./cmd/api
go test -v ./... 
```
