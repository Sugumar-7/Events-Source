/*
    Copyright (c) 2017 Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2018
* @group Utilities
* @description Object- and field-level security checks
*/
global without sharing class ct_UTIL_Permissions {

    private final static String INSUFFICIENT_PERMISSION_MESSAGE = 'Insufficient access, please contact your administrator';//System.Label.flsError;

    private static ct_UTIL_Permissions utilPermissionsInstance;
 	
     /*** Object Level Security ***/

    /**
    * @description Determines whether the running user has read permissions on the given object
    * @param objectName the name of the object
    * @return returns true if the user has permission; throws an exception not
    */
    global static Boolean canRead(String objectName) {
        return canRead(objectName, true);
    }
    /**
    * @description Determines whether the running user has read permissions on the given object
    * @param objectName the name of the object
    * @param throwException indicates whether an exception should be thrown if the user doesn't have permission
    * @return returns boolean to indicate whether the user has permission; conditionally throws an exception not
    */
    global static Boolean canRead(String objectName, Boolean throwException) {
        if (!ct_Util.getObjectDescribe(objectName).isAccessible()) {
            if (throwException) {
                throw new InsufficientPermissionException(INSUFFICIENT_PERMISSION_MESSAGE);
            } else {
                return false;
            }
        }
        return true;
    }
    /**
    * @description Determines whether the running user has read permissions on the given object and field
    * @param objectName the name of the object
    * @param fieldName the name of the field
    * @param throwException indicates whether an exception should be thrown if the user doesn't have permission
    * @return returns boolean to indicate whether the user has permission; conditionally throws an exception not
    */
    global static Boolean canRead(String objectName, String fieldName, Boolean throwException) {
        DescribeFieldResult fieldResult = ct_Util.getFieldDescribe(objectName, fieldName);
        return canRead(fieldResult, throwException);
    }
    
    /**
    * @description Determines whether the running user has read permissions on the given field
    * @param fieldResult the DescribeFieldResult of the field to check
    * @param throwException indicates whether an exception should be thrown if the user doesn't have permission
    * @return returns boolean to indicate whether the user has permission; conditionally throws an exception not
    */
    global static Boolean canRead(DescribeFieldResult fieldResult, Boolean throwException) {
        if (!fieldResult.isAccessible()) {
            if (throwException) {
                throw new InsufficientPermissionException(INSUFFICIENT_PERMISSION_MESSAGE);
            } else {
                return false;
            }
        }
        return true;
    }

    
     global class InsufficientPermissionException extends Exception {}


}