name: Deploy Flask App to AWS with Terraform

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy to AWS
    runs-on: ubuntu-latest

    steps:
      # 1️⃣ Checkout the repo
      - name: Checkout code
        uses: actions/checkout@v3

      # 2️⃣ Log in to Docker Hub
      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      # 3️⃣ Build and push Docker image
      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/flask-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/flask-app:latest

      # 4️⃣ Set up Terraform CLI
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.7

      # 5️⃣ Terraform init & apply to deploy EC2
      - name: Deploy Infrastructure with Terraform
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve
