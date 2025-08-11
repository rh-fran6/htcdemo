# HTC Engagement Demo - User Documentation

Welcome to the HTC Engagement Demo repository! This guide is designed for basic users and provides an easy-to-follow overview of the project and its main components.

---

## Getting Started

### 1. Clone the Repository

Open your terminal and run:
```sh
git clone https://github.com/rh-fran6/htcdemo.git
cd htcdemo
```

---

## Preliminaries: Secrets Management

### 2. Create and Populate Your Secrets File

1. Navigate to the `secrets` directory:
    ```sh
    cd secrets
    ```

2. Create a file named `sample.yaml` and populate it with the following template.  
   Replace the placeholder values with your actual credentials:
   ```yaml
   secrets:
     github_token: <your-github-PAT>
     access-key-id: <AWS Access Key ID>
     secret_access_key: <AWS Access Secret>
   ```

### 3. Encrypt the Secrets File with Ansible Vault

To keep your secrets safe, encrypt `sample.yaml` using Ansible Vault. The output should be saved as `secrets/encrypted-secrets.yaml`:

```sh
ansible-vault encrypt sample.yaml --output encrypted-secrets.yaml
```
You will be prompted to set a password. Save this password securely.

- **Note:** You should now see `encrypted-secrets.yaml` in the `secrets` folder.  
- Do **not** share your secrets or the Ansible Vault password.

---

## Makefile Commands

The repository provides helpful automation via `Makefile`. The two main commands for basic users are:

### 4. Run Local Demo

```sh
make run
```
- This command sets up and runs the demo locally.
- It may use your encrypted secrets and automation scripts to start the necessary services.

### 5. Deploy the Demo

```sh
make deploy
```
- This command deploys the demo to the target environment (such as a test server or cloud provider).
- Make sure your secrets file is properly encrypted and available before running this.

---

## Summary of Folders

- **ansible/**: Automation scripts for setup and deployment.
- **clusterbootstrap/**: Files for initializing clusters and environments.
- **secrets/**: Store your secret files here, such as `sample.yaml` and `encrypted-secrets.yaml`. Always encrypt with Ansible Vault.

---

## Security Notes

- Never share your secrets or the Ansible Vault password.
- Always keep `encrypted-secrets.yaml` encrypted unless actively editing values.

---

## Getting Help

If you need more information or run into issues, reach out to your project lead or the repository owner: [rh-fran6](https://github.com/rh-fran6).

---

This documentation is designed to help basic users start working with the HTC Engagement Demo quickly and securely.