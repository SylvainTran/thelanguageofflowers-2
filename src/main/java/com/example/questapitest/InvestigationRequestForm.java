package com.example.questapitest;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Map;

public class InvestigationRequestForm {

    ValidFormRequest validFormRequest;
    String keywordsConcat = "";
    String validRequestResponse = "";
    String validRequestResponseKey = "";

    public InvestigationRequestForm(String requestType, ArrayList<String> keywords) {
        keywords.forEach(keyword -> keywordsConcat += (keyword.trim().toLowerCase()));
        validFormRequest = new ValidFormRequest(requestType, keywords, keywordsConcat);
    }

    public ValidFormRequest getValidFormRequest() {
        return validFormRequest;
    }

    @Override
    public String toString() {
        return "Request Type: " + validFormRequest.getRequestType() + "\n" + keywordsConcat;
    }

    public String getData() {
        try {
            ObjectMapper mapper = new ObjectMapper();
            InputStream is = getClass().getResourceAsStream("/json/InvestigationFormsData.json");
            Map<String, ValidFormRequest[]> listRequests = mapper.readValue(is, new TypeReference<Map<String, ValidFormRequest[]>>(){});
            ValidFormRequest[] arr = listRequests.get(validFormRequest.getRequestType());

            for (int i = 0; i < arr.length; i++) {
                if (arr[i].equals(validFormRequest)) {
                    System.out.println("Found: " + arr[i]);
                    validRequestResponse = arr[i].getResponse();
                    validRequestResponseKey = arr[i].getResponseKey();
                }
            }
            System.out.println("Valid request response: " + validRequestResponse);
            ObjectNode responseObject = mapper.createObjectNode();
            responseObject.put("response", validRequestResponse);
            responseObject.put("eventKey", validRequestResponseKey);
            String jsonResponse = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(responseObject);
            System.out.println(jsonResponse);
            return jsonResponse;
        }
        catch( com.fasterxml.jackson.core.JsonProcessingException e) {
            System.err.println(e.getMessage());
        }
        catch (java.io.IOException e) {
            System.err.println(e.getMessage());
        }
        catch (NullPointerException e) {
            System.err.println(e.getMessage());
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }
}
