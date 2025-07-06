name: Deploy Flask App to AWS with Terraform

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout repo
      - name: Checkout code
        uses: actions/checkout@v3

      # Step 2: Set up Terraform
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.7

      # Step 3: Docker Login
      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      # Step 4: Build & Push Docker Image
      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/flask-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/flask-app:latest

      # Step 5: Run Terraform from terraform/ directory
      - name: Deploy Infrastructure with Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.7

      - name: Terraform Init and Apply
        working-directory: terraform
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          terraform init
          terraform apply -auto-approve
