gcloud auth list
gcloud projects list
gcloud iam service-accounts create stage-provisioner --description "Staging env provisioning" --display-name "stage-provisioner"
gcloud iam service-accounts list
gcloud iam service-accounts keys create stage-provisioner-credentials.json --iam-account
stage-provisioner@ci-cid-stage.iam.gserviceaccount.com
gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE

gcloud projects add-iam-policy-binding ci-cid-stage --member serviceAccount:stage-provisioner@ci-cid-stage.iam.gserviceaccount.com --role roles/editor
ssh-keygen.exe -t rsa -f D:/Workspace/GCP/stage/stage-provisioner-key -C "stage-provisioner"
gcloud auth activate-service-account --key-file=D:\Workspace\GCP\config\stage-provisioner-credentials.json
