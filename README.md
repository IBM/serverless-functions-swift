<p align="center">
    <a href="https://cloud.ibm.com">
        <img src="https://landscape.cncf.io/logos/ibm-cloud.svg" height="100" alt="IBM Cloud">
    </a>
</p>


<p align="center">
    <a href="https://cloud.ibm.com">
    <img src="https://img.shields.io/badge/IBM%20Cloud-powered-blue.svg" alt="IBM Cloud">
    </a>
    <img src="https://img.shields.io/badge/platform-swift-lightgrey.svg?style=flat" alt="platform">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>


# Create a serveless Swift application

> We have similar applications available for [Node.js](https://github.com/IBM/serverless-app-nodejs) and [Python](https://github.com/IBM/serverless-app-python).


This repository has code to create a serverless Backend for Frontend (BFF) using Swift and IBM Cloud Functions, backend by a NoSQL database. No full stack application management required. Cloud Functions supplies basic Create, Read, Update, and Delete operations in a serverless environment. These functions are mapped to an API gateway, which can be integrated into an iOS app, for example, to enable persistence of data into a Cloudant NoSQL Database.

## Included Components

* [Cloudant NoSQL DB](https://cloud.ibm.com/catalog/services/cloudant): A fully managed data layer designed for modern web and mobile applications that leverages a flexible JSON schema.
* [API Connect](http://developer.ibm.com/apiconnect/): Create and run secure APIs and microservices.
* [Continuous Delivery](https://cloud.ibm.com/catalog/services/continuous-delivery): Enable tool integrations that support your development, deployment, and operation tasks.
* [GitLab](https://about.gitlab.com/): GitLab unifies issues, code review, CI, and CD into a single UI.
* [AppID](https://cloud.ibm.com/catalog/services/app-id): Use the IBM Cloud App ID service to add authentication to your mobile and web apps and protect your back-end systems.

## Featured Technologies

* [Serverless](https://cloud.ibm.com/openwhisk): An event-action platform that allows you to execute code in response to an event.
* [Swift](https://developer.apple.com/swift/): An open-source programming language for Apple devices.

## Steps

1. [Install developer tools](#1-install-developer-tools)
1. [Configure your DevOps pipeline](#2-configure-your-devops-pipeline)
1. [Deploy your serverless application](#3-deploy-your-serverless-application)
1. [Integrate with your own frontend application](#4-integrate-with-your-own-frontend-application)

### 1. Install developer tools

- [IBM Cloud CLI](https://cloud.ibm.com/docs/cli/reference/ibmcloud/download_cli.html)
- Cloud Functions Plugin:
  ```bash
  ibmcloud plugin install Cloud-Functions -r IBM Cloud
  ```
- [Whisk Deploy CLI](https://github.com/apache/incubator-openwhisk-wskdeploy/releases)

### 2. Configure your DevOps pipeline

The `.bluemix` directory contains all of the configuration files that the toolchain requires to function. At a minimum, the `.bluemix` directory must contain the following files:

- `toolchain.yml`
- `deploy.json`
- `pipeline.yml`

Detailed information regarding toolchain configuration can be found in our [docs](https://cloud.ibm.com/docs/services/ContinuousDelivery/toolchains_custom.html#toolchains_custom).

Update the toolchain (`.bluemix/toolchain.yml`) with your desired changes.

Login into the IBM Cloud, substituting your own values for `<api>`, `<org>`, and `<space>`:

```bash
ibmcloud login -a <api> -o <org> -s <space>
```

Push your application to stage the toolchain:

```bash
ibmcloud app push
```

### 3. Deploy your serverless application

Your application is deployed using the IBM Continuous Delivery pipeline. Your toolchain provides an integrated set of tools to automatically build, deploy, and manage your apps.

#### Manage Cloud Functions and API Connect Manually

Download your code locally by navigate to your App dashboard from the [Apple Development Console](https://cloud.ibm.com/developer/appledevelopment/apps) or [Web Apps Console](https://cloud.ibm.com/developer/appservice/apps) and select **Download Code**.

You have the option to perform either a [Local Deployment](#local-deployment) or an [IBM DevOps deployment](#ibm-devops-deployment).

##### Local Deployment

If you're on Mac or Linux, ensure the `deploy.sh` script is executable and run it:

```
chmod +x deploy.sh
./deploy.sh
```

Or, if you'd rather run the `wskdeploy` command directly, you use the `--param` command line flags to provide values for the `services.cloudant.database` and `services.cloudant.url` values.

```bash
/wskdeploy -m "manifest.yml" --param "services.cloudant.url" "<url>" --param "services.cloudant.database" "products"
```

Where `<url>` is the URL value from your Cloudant service credentials.

### 4. Integrate with your own frontend application

Cloudant NoSQL DB provides access to a fully managed NoSQL JSON data layer that's always-on. This service is compatible with CouchDB, and accessible through a simple to use HTTP interface for mobile and web application models.

You can then review the [Actions](https://cloud.ibm.com/openwhisk/actions) in the IBM Cloud Console interface, along with your [Cloud Functions APIs](https://cloud.ibm.com/openwhisk/apimanagement).
<table>
  <thead>
      <tr>
        <th>Method</th>
        <th>HTTP request</th>
        <th>Description</th>
      </tr>
  </thead>
  <tbody>
    <tr>
      <td>Create</td>
      <td>POST /database</td>
      <td>Inserts an object</td>
    </tr>
    <tr>
      <td>Read</td>
      <td>GET /database/<font color="#ec407a">objectId</font></td>
      <td>Retrieves an object</td>
    </tr>
    <tr>
      <td>ReadAll</td>
      <td>GET /database</td>
      <td>Retrieves all objects</td>
    </tr>
    <tr>
      <td>Delete </td>
      <td>DELETE /database/<font color="#ec407a">objectId</font></td>
      <td>Deletes an object</td>
    </tr>
    <tr>
      <td>DeleteAll</td>
      <td>DELETE /database</td>
      <td>Deletes all objects</td>
    </tr>
    <tr>
      <td>update</td>
      <td>PUT /database/<font color="#ec407a">objectId</font></td>
      <td>Updates content of an object</td>
    </tr>
  </tbody>
</table>

## Next Steps
* Learn more about augmenting your Swift applications on IBM Cloud with the [Swift Programming Guide](https://cloud.ibm.com/docs/swift).
* Explore [Kitura.io](https://www.kitura.io/) for more resources about the Kitura framework.
* Join the [Swift@IBM slack](http://swift-at-ibm-slack.mybluemix.net/) to get help with your projects.
* Explore other [sample applications](https://cloud.ibm.com/developer/appservice/starter-kits) on IBM Cloud.

## License

[Apache 2.0](LICENSE)
