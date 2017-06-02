//
//  Alamofire+GithubAPI.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/17/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import Alamofire
import Apollo

func newGithubClient(
    sessionManager: GithubSessionManager,
    userSession: GithubUserSession? = nil
    ) -> GithubClient {
    var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders

    // for apollo + github gql endpoint
    // http://dev.apollodata.com/ios/initialization.html
    if let token = userSession?.authorization.token {
        additionalHeaders["Authorization"] = "Bearer \(token)"
    }

    let config = URLSessionConfiguration.default
    // disable URL caching for the v3 API
    config.urlCache = nil
    config.httpAdditionalHeaders = additionalHeaders

    let networker = Alamofire.SessionManager(configuration: config)

    let gqlURL = URL(string: "https://api.github.com/graphql")!
    let transport = HTTPNetworkTransport(url: gqlURL, configuration: config)
    let apollo = ApolloClient(networkTransport: transport)

    return GithubClient(
        sessionManager: sessionManager,
        apollo: apollo,
        networker: networker,
        userSession: userSession
    )
}
