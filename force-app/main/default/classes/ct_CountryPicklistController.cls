/**
 * @File Name          : ct_CountryPicklistController.cls
 * @Description        : 
 * @Author             : Javid Sherif
 * @Group              : 
 * @Last Modified By   : Creation Admin
 * @Last Modified On   : 17/4/2020, 6:32:04 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/4/2020   Javid Sherif     Initial Version
**/

global without sharing class ct_CountryPicklistController {

    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getCountryStateMap(){

        Map<String, Object> result = new Map<String, Object>();

        Boolean isPicklistEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('ShippingCountryCode');

        result.put('isPicklistEnabled', isPicklistEnabled);

        // If NOT enabled → return static resource data
        if(!isPicklistEnabled){

            Map<String, List<String>> countryStateMap =
                new Map<String, List<String>>();

            StaticResource sr = [
                                    SELECT Body
                                    FROM StaticResource
                                    WHERE Name = 'ct_CountryStateValues'
                                    LIMIT 1
                                ];

            String contents = blobToString(sr.Body,'ISO-8859-1');
            String[] lines = contents.split('\n');

            for(Integer i = 1; i < lines.size(); i++){
                String[] row = lines[i].split(',');

                if(row.size() < 2) continue;

                String country = row[0].trim();
                String state = row[1].trim();

                if(!countryStateMap.containsKey(country)){
                    countryStateMap.put(country, new List<String>());
                }
                countryStateMap.get(country).add(state);
            }
            result.put('staticData', countryStateMap);
        }
        return result;
    }

    global static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];

        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] = hex.mid(i << 1, 2);

        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
}