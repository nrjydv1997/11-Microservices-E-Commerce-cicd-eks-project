# 🛒 Microservices E-Commerce Application on AWS EKS

A production-ready deployment of a full **11-service microservices e-commerce platform** on **Amazon EKS** using Jenkins CI/CD, ArgoCD GitOps, Terraform, Docker, and Kubernetes.

---

## 📦 Services

| Service | Language | Port |
|---|---|---|
| adservice | Java | 9555 |
| cartservice | Go | 7070 |
| checkoutservice | Go | 5050 |
| currencyservice | Node.js | 7000 |
| emailservice | Python | 5000 |
| frontend | Go | 80 |
| loadgenerator | Python | - |
| paymentservice | Node.js | 50051 |
| productcatalogservice | Go | 3550 |
| recommendationservice | Python | 8080 |
| shippingservice | Go | 50051 |

---

## 🏗️ Architecture

```
GitHub → Jenkins CI/CD → Docker Build → ECR → ArgoCD → EKS (dev namespace)
                                                            ↑
                                               Terraform (VPC, EKS, ECR)
```

---

## 🛠️ Prerequisites

- AWS CLI configured
- Terraform installed
- kubectl installed
- eksctl installed
- Helm installed
- Docker installed
- Jenkins (auto-provisioned via Terraform)

---

## 🚀 Deployment Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/nrjydv1997/11-Microservices-E-Commerce-cicd-eks-project.git
cd 11-Microservices-E-Commerce-cicd-eks-project
```

### Step 2: Configure AWS Credentials

```bash
aws configure
# Provide: Access Key ID, Secret Access Key, Region, Output format
```

### Step 3: Create S3 Buckets for Terraform State

```bash
cd s3-buckets/
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 4: Provision Network Infrastructure & EC2 (Jenkins)

```bash
cd ../terraform_main_ec2
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 5: Access Jenkins

```
http://<EC2_PUBLIC_IP>:8080
```

Get the initial admin password:

```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

Install suggested plugins and create your first admin user.

### Step 6: Install Jenkins Plugins

Go to **Manage Jenkins → Plugins → Available** and install:
- Pipeline: Stage View

Restart Jenkins after installation.

### Step 7: Create EKS Cluster via Jenkins Pipeline

1. New Item → Name: `eks-terraform` → Pipeline
2. Pipeline from SCM → Git
3. Repo: `https://github.com/nrjydv1997/11-Microservices-E-Commerce-cicd-eks-project.git`
4. Branch: `*/main`
5. Script Path: `eks-terraform/eks-jenkinsfile`
6. Build with Parameters → ACTION: `apply`

Verify:

```bash
aws eks --region us-east-1 update-kubeconfig --name project-eks
kubectl get nodes
```

### Step 8: Create ECR Repositories via Jenkins Pipeline

1. New Item → Name: `ecr-terraform` → Pipeline
2. Script Path: `ecr-terraform/ecr-jenkinfile`
3. Build with Parameters → ACTION: `apply`

Verify:

```bash
aws ecr describe-repositories --region us-east-1
```

### Step 9: Add GitHub PAT to Jenkins Credentials

1. Manage Jenkins → Credentials → Global → Add Credentials
2. Kind: `Secret text`
3. ID: `my-git-pattoken`
4. Secret: `<your GitHub PAT>`

### Step 10: Build & Push Docker Images to ECR

Create a Jenkins Pipeline job for each service with the following settings:

| Service | Script Path |
|---|---|
| emailservice | `jenkinsfiles/emailservice` |
| checkoutservice | `jenkinsfiles/checkoutservice` |
| recommendationservice | `jenkinsfiles/recommendationservice` |
| frontend | `jenkinsfiles/frontend` |
| paymentservice | `jenkinsfiles/paymentservice` |
| productcatalogservice | `jenkinsfiles/productcatalogservice` |
| cartservice | `jenkinsfiles/cartservice` |
| loadgenerator | `jenkinsfiles/loadgenerator` |
| currencyservice | `jenkinsfiles/currencyservice` |
| shippingservice | `jenkinsfiles/shippingservice` |
| adservice | `jenkinsfiles/adservice` |

For each: New Item → Pipeline → SCM: Git → Repo URL → Branch `*/main` → Script Path (from table above) → Build.

---

## 🔄 ArgoCD Setup (GitOps)

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
```

### Expose ArgoCD UI

```bash
kubectl edit svc argocd-server -n argocd
# Change type: ClusterIP → type: LoadBalancer

kubectl get svc argocd-server -n argocd
```

### Get Admin Password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Login at `https://<ARGOCD_EXTERNAL_IP>` with username `admin`.

### Deploy Application via ArgoCD

1. Create namespace: `kubectl create namespace dev`
2. In ArgoCD UI → **+ NEW APP**:
   - Application Name: `project`
   - Project: `default`
   - Sync Policy: `Automatic`
   - Repo URL: `https://github.com/nrjydv1997/11-Microservices-E-Commerce-cicd-eks-project.git`
   - Revision: `HEAD`
   - Path: `kubernetes-files`
   - Cluster URL: `https://kubernetes.default.svc`
   - Namespace: `dev`
3. Click **Create**

---

## 🌐 HTTPS Setup with Route 53 + ACM + CLB

### 1. Create Route 53 Hosted Zone

- Domain: `your-domain.com`
- Type: Public Hosted Zone
- Copy the 4 NS records to your domain registrar (e.g., Hostinger)

### 2. Request SSL Certificate in ACM

- Go to ACM → Request Certificate → Public
- Enter your domain and `www.your-domain.com`
- Choose DNS validation → Create DNS record in Route 53
- Wait for status: **Issued**

### 3. Add HTTPS Listener to Load Balancer

- EC2 → Load Balancers → Select CLB → Listeners
- Add: Protocol `HTTPS`, Port `443`, SSL cert from ACM

### 4. Update Security Group

- Add inbound rule: HTTPS / TCP / 443 / `0.0.0.0/0`

### 5. Create Route 53 A Record

- Type: A (Alias)
- Alias Target: Your frontend Load Balancer DNS
- Click Create Record

### 6. Verify

```bash
curl -v https://your-domain.com
```

---

## 📊 Kubernetes Monitoring with Prometheus & Grafana

Monitor your EKS cluster using the **kube-prometheus-stack** Helm chart which installs Prometheus, Grafana, Alertmanager, and all required exporters in one go.

---

### Step 1: Add the Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

### Step 2: Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

---

### Step 3: Install kube-prometheus-stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.service.type=LoadBalancer
```

Verify all pods are running:

```bash
kubectl get pods -n monitoring
```

Expected output:

```
NAME                                                   READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager   2/2     Running   0          2m
prometheus-grafana-xxxx                                3/3     Running   0          2m
prometheus-kube-prometheus-operator-xxxx               1/1     Running   0          2m
prometheus-kube-state-metrics-xxxx                     1/1     Running   0          2m
prometheus-prometheus-kube-prometheus-prometheus-0     2/2     Running   0          2m
prometheus-prometheus-node-exporter-xxxx               1/1     Running   0          2m
```

---

### Step 4: Access Grafana UI

Get the Grafana LoadBalancer URL:

```bash
kubectl get svc -n monitoring | grep grafana
```

Open in browser:

```
http://<GRAFANA_EXTERNAL_IP>
```

Default login credentials:

| Field | Value |
|---|---|
| Username | `admin` |
| Password | `prom-operator` |

> To get password if changed:
> ```bash
> kubectl get secret prometheus-grafana -n monitoring \
>   -o jsonpath="{.data.admin-password}" | base64 -d && echo
> ```

---

### Step 5: Access Prometheus UI

```bash
kubectl get svc -n monitoring | grep prometheus
```

Expose Prometheus (if needed):

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090 -n monitoring
```

Open: `http://localhost:9090`

---

### Step 6: Import Grafana Dashboards

Grafana comes with pre-built Kubernetes dashboards. To import additional ones:

1. Go to Grafana UI → **Dashboards → Import**
2. Enter Dashboard ID and click **Load**

| Dashboard | ID |
|---|---|
| Kubernetes Cluster Overview | `315` |
| Kubernetes Pod Monitoring | `6417` |
| Node Exporter Full | `1860` |
| Kubernetes Deployment | `8588` |

---

### Step 7: Verify Metrics Collection

In Prometheus UI → go to **Status → Targets** to confirm all scrape targets are `UP`:

- `kubelet`
- `kube-apiserver`
- `node-exporter`
- `kube-state-metrics`
- `alertmanager`

---

### Step 8: Configure Alertmanager (Optional)

Edit the Alertmanager config to send alerts to Slack/Email:

```bash
kubectl edit secret alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring
```

Example Slack config:

```yaml
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  receiver: 'slack-notifications'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - channel: '#alerts'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}'
```

---

### Monitoring Architecture

```
EKS Nodes & Pods
      ↓
Node Exporter + kube-state-metrics
      ↓
Prometheus (scrapes metrics)
      ↓
Grafana (visualizes dashboards)
      ↓
Alertmanager (sends alerts → Slack/Email)
```

---

### Uninstall Monitoring Stack

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

---

## 🔧 Troubleshooting

| Issue | Fix |
|---|---|
| Terraform state lock | `terraform force-unlock <LOCK_ID>` |
| Jenkins Git auth failure | Update PAT token in Jenkins credentials |
| Docker build native module error | Add `python3 make g++` / `gcc linux-headers` to Dockerfile |
| Pod CrashLoopBackOff | Check `kubectl logs <pod> -n dev` |
| HTTPS timeout | Verify port 443 open in Security Group, ACM cert status = Issued |

---

## 📁 Project Structure

```
.
├── s3-buckets/              # Terraform - S3 state buckets
├── terraform_main_ec2/      # Terraform - VPC, EC2, Jenkins
├── eks-terraform/           # Terraform - EKS cluster
├── ecr-terraform/           # Terraform - ECR repositories
├── jenkinsfiles/            # Jenkins pipeline scripts per service
├── kubernetes-files/        # Kubernetes manifests (Deployments + Services)
└── src/                     # Microservice source code
    ├── adservice/
    ├── cartservice/
    ├── checkoutservice/
    ├── currencyservice/
    ├── emailservice/
    ├── frontend/
    ├── loadgenerator/
    ├── paymentservice/
    ├── productcatalogservice/
    ├── recommendationservice/
    └── shippingservice/
```

---

## 👤 Author

**Neeraj Yadav**  
DevOps Engineer | AWS | Kubernetes | CI/CD

---

## 📄 License

This project is for educational purposes.
