/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MPL-2.0
 */

// Lambda function code
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");

class ParameterStore {
  constructor(region) {
    this.ssmClient = new SSMClient({
      region: region,
    });
  }

  async getParameterValue(parameterName) {
    try {
      const input = {
        Name: parameterName,
        WithDecryption: true,
      };

      const command = new GetParameterCommand(input);
      const response = await this.ssmClient.send(command);
      const parameterValue = response.Parameter.Value;

      return parameterValue;
    } catch (error) {
      console.error("Error retrieving parameter value:", error);
      throw error;
    }
  }

  // Singleton pattern to ensure a single instance of ParameterStore is used
  static getInstance() {
    if (!ParameterStore.instance) {
      ParameterStore.instance = new ParameterStore("ap-southeast-2");
    }
    return ParameterStore.instance;
  }
}

module.exports.handler = async (event) => {
  console.log("Event: ", event);
  let databasePwd = {};
  try {
    const parameterStore = ParameterStore.getInstance();
    const parameterName = "/development/MONGODB_PWD";
    const databasePwd = await parameterStore.getParameterValue(parameterName);
    console.log(databasePwd);
  } catch (e) {
    console.error(e);
  }

  let responseMessage = "Hello, World!";

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      encryptedValue: databasePwd,
      message: responseMessage,
    }),
  };
};
