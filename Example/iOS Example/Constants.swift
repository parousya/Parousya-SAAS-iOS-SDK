//
//  Constants.swift
//  iOS Example
//
//  Created by Xuan Jie Chew on 09/08/2019.
//  Copyright (c) 2019 Parousya. All rights reserved.
//

public struct ParousyaSAASSampleClientConstants {
#if DEBUG
	static let appKey = "DEV_APP_KEY"
	static let appSecret = "DEV_APP_SECRET"
#else
	static let appKey = "PROD_APP_KEY"
	static let appSecret = "PROD_APP_SECRET"
#endif
	
	static let userIdKey = "USER_ID_KEY"
	static let userTypeKey = "USER_TYPE_KEY"
}
