var SEND_INVITATION_TYPE = 0;
var ACCEPT_INVITATION_TYPE = 1;
var DECLINE_INVITATION_TYPE = 2;

var SEND_REQUEST_TYPE = 3;
var ACCEPT_REQUEST_TYPE = 4;
var DECLINE_REQUEST_TYPE = 5;

var SEND_RECOMMENDATION_TYPE = 6;

var USER_FOLLOWED_TYPE = 7;

/******** HELPER METHODS ********/

/**
 * Sends push to user
 * @param recipientId
 * @param text
 */
Parse.Cloud.define("helper_SendPush", function(request, response) {
    // SEND PUSH
    var user = new Parse.User();
    user.id = request.params.recipientId;

    // Find devices associated with these users
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);

    var pushString = "Hi!";
    if (request.params.text) {
        pushString = request.params.text;
    }

    // Send push notification to query
    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: pushString
        }
    }, {
        success: function() {
            console.log("sent push");
            response.success("went well");
        },
        error: function(error) {
            console.log(error);
            response.success("didn't send a push");
            // Handle error
        }
    });

});

/**
 * Helper function to create a new invite
 * @param senderId
 * @param recipientId
 * @param partyId
 * @param type a constant from the list above
 */
Parse.Cloud.define("helper_SendInvite", function(request, response) {
    var Invitation = Parse.Object.extend("Invitation");
    var invite = new Invitation();

    var sender = new Parse.User();
    sender.id = request.params.senderId;

    var recipient = new Parse.User();
    recipient.id = request.params.recipientId;

//    console.log("SENDER " + obj.get("username") + " id " + obj.id);
//    console.log("RECIPIENT " + obj2.get("username") + " id " + obj2.id);

    var Party = Parse.Object.extend("Party");
    var party = new Party();
    party.id = request.params.partyId;

    invite.set("type", request.params.type);
    invite.set("sender", sender);
    invite.set("recipient", recipient);

    var type = request.params.type;
    console.log("TYPE === " + type);
    if (type == SEND_REQUEST_TYPE || type == SEND_INVITATION_TYPE) {
        invite.set("didRespond", false);
    } else invite.set("didRespond", true);

    if (request.params.partyId) {
        invite.set("party", party);
    } else {
        invite.set("party", null);
    }

    invite.save().then(
        function(invite) {
            console.log("Invite " + invite + " was saved!");
            response.success("went well");
        }, function(error) {
            console.log("Invite " + invite + " error = " + error);
            response.error(error);
        }
    );
});

/**
 * Changes invitation's didRespond to true
 * @param invitationId
 */
Parse.Cloud.define("helper_UpdateInvitation", function(request, response) {
    var Invitation = Parse.Object.extend("Invitation");
    var invitation = new Invitation();
    invitation.id  = request.params.invitationId;
    invitation.set("didRespond", true);

    invitation.save(null, {
        success: function(myObject) {
            console.log("invitation " + myObject + " updated");
            response.success("went well");
        },
        error: function(error) {
            console.log("object " + myObject + " error = " + error);
            response.error("smth wrong");
        }
    });
});

/**
 * Deletes invitation
 * @param invitationId
 */
Parse.Cloud.define("helper_DeleteInvitation", function(request, response) {
    var Invitation = Parse.Object.extend("Invitation");
    var invitation = new Invitation();
    invitation.id  = request.params.invitationId;

    invitation.destroy({
        success: function(myObject) {
            console.log("invitation " + myObject + " destroyed");
            response.success("went well");
        },
        error: function(error) {
            console.log("object " + myObject + " error = " + error);
            response.error("smth wrong");
        }
    });
});

/**
 * Adds user to the invited list
 * @param userId id of the user who we add to the list
 * @param partyId
 */
Parse.Cloud.define("helper_AddToInvitedList", function(request, response) {
    var Party = Parse.Object.extend("Party");
    var partyPtr = new Party();
    partyPtr.id = request.params.partyId;
    partyPtr.fetch().then(function(party){
        var relation = party.relation("invited");

        user = new Parse.User();
        user.id = request.params.userId;
        relation.add(user);

        party.save().then(function(party) {
            response.success("went well");
        }, function(error) {
            response.error(error);
        });
    }, function(error) {
        response.error(error);
    });
});

/**
 * Creates a new event with type = 1 friend goes to party
 * @param userId
 * @param partyId
 */
Parse.Cloud.define("helper_CreateIventFriendGoesToParty", function(request, response) {
    var Party = Parse.Object.extend("Party");
    var party = new Party();
    party.id = request.params.partyId;

    var user = new Parse.User();
    user.id = request.params.userId;

    // Создаем Event с type = 1 - друг идет на пати
    var Event = Parse.Object.extend("Event");
    var event = new Event();
    event.set("type", 1);
    event.set("party", party);
    event.set("owner", user);

    event.save().then(function(obj) {
        response.success("went well");
    }, function(error) {
        response.error(error);
    });
});

/******** HELPER METHODS END ********/

/**
 * Sends invite to the party
 * @param partyId
 * @param recipientId id of the user whom we send the invite
 * @param pushText parse push text
 */
Parse.Cloud.define("sendInvite", function(request, response) {
    console.log(request.params);

    Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_INVITATION_TYPE}, {
        success: function(result) {
            Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                success: function(result) {
                    response.success("went well");
                },
                error: function(error) {
                    response.success("went well, but didn't send push");
                }
            });
        },
        error: function(error) {
            response.error(error);
        }
    });

});

/**
 * Accept invitation to the party
 * @param partyId
 * @param recipientId ID of the party creator
 * @param invitationId ID of the accepted invitation
 * @param pushText
 */
Parse.Cloud.define("acceptInvitation", function(request, response) {
    console.log(request.params);

    Parse.Cloud.run("helper_UpdateInvitation", {"invitationId": request.params.invitationId}, {
        success: function(myObject) {
            console.log("invitation " + myObject + " destroyed");
            Parse.Cloud.run("helper_AddToInvitedList", {"userId": request.user.id, "partyId": request.params.partyId}, {
//            Parse.Cloud.run("helper_AddToInvitedList", {"userId": request.params.userId, "partyId": request.params.partyId}, {
                success: function(party) {

                    // Создаем извещение о том, что мы приняли приглашение
                    Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": ACCEPT_INVITATION_TYPE}, {
//                USED FOR TESTING    Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": ACCEPT_INVITATION_TYPE}, {
                        success: function (invitation) {

                            Parse.Cloud.run("helper_CreateIventFriendGoesToParty", {"userId": request.user.id, "partyId": request.params.partyId}, {
//                     USED FOR TESTING       Parse.Cloud.run("helper_CreateIventFriendGoesToParty", {"userId": request.params.userId, "partyId": request.params.partyId}, {
                                success: function (event) {
                                    Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                                        success: function(result) {
                                            response.success("went well");
                                        },
                                        error: function(error) {
                                            response.success("went well, but didn't send push");
                                        }
                                    });
                                },
                                error: function (myObject, error) {
                                    console.log("object " + myObject + " error = " + error);
                                    response.error("FAILED to save Event with type = 1");
                                }
                            });

                        },
                        error: function (myObject, error) {
                            console.log("object " + myObject + " error = " + error);
                            response.error("FAILED to save Invitation with type = 1");
                        }
                    });
                },
                error: function(object, error) {
                    console.log("object " + object + " error = " + error);
                    response.error("FAILED to save party update : " + error);
                }
            });
        },
        error: function(myObject, error) {
            console.log("object " + myObject + " error = " + error);
            response.error("FAILED to destroy invitation : " + error);
        }
    });

});

/**
 * Decline invitation to the party
 * @param invitationId
 * @param partyId
 * @param recipientId
 * @param pushText
 */
Parse.Cloud.define("declineInvitation", function(request, response) {
    console.log(request.params);

    Parse.Cloud.run("helper_UpdateInvitation", {"invitationId": request.params.invitationId}, {
        success: function (myObject) {
            console.log("invitation " + myObject + " destroyed");

            Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": DECLINE_INVITATION_TYPE}, {
//      FOR TESTING      Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "party": request.params.partyId, "type": DECLINE_INVITATION_TYPE}, {
                success: function(myOjb) {
                    Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                        success: function(result) {
                            response.success("went well");
                        },
                        error: function(error) {
                            response.success("went well, but didn't send push");
                        }
                    });
                },
                error: function(error) {
                    response.error(error);
                }
            });

        },
        error: function (myObject, error) {
            console.log("object " + myObject + " error = " + error);
            response.error("smth wrong");
        }
    });
});

/**
 * Sends request to private party
 * @param partyId
 * @param recipientId creator of the party
 * @param pushText
 */
Parse.Cloud.define("sendRequest", function(request, response) {

    var Party = Parse.Object.extend("Party");
    var party = new Party();
    party.id = request.params.partyId;
    party.fetch().then(function(partyObj) {
        var capacity = partyObj.get("capacity");
        if (capacity == 0) {
            Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_REQUEST_TYPE}, {
                success: function (myObj) {
                    Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                        success: function(result) {
                            response.success("went well");
                        },
                        error: function(error) {
                            response.success("went well, but didn't send push");
                        }
                    });
                },
                error: function (error) {
                    response.error(error);
                }
            });
        } else {
            var invitedRelationQuery = partyObj.relation("invited").query();
            invitedRelationQuery.count().then(function (totalInvited) {
                if (capacity - totalInvited > 0) {
//                Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_REQUEST_TYPE}, {
                    Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_REQUEST_TYPE}, {
                        success: function (myObj) {
                            Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                                success: function(result) {
                                    response.success("went well");
                                },
                                error: function(error) {
                                    response.success("went well, but didn't send push");
                                }
                            });
                        },
                        error: function (error) {
                            response.error(error);
                        }
                    });
                } else { // create error not enough space
                    response.error({"code": 1, "message": "Not enough space!"});
                }
            }, function (error) {
                response.error(error);
            });
        }
    }, function(error) { response.error(error); });

});

/**
 * Creator of the party accepts request
 * @param partyId party to which the invite was requested
 * @param invitationId id of the invitaion that requested an invite
 * @param recipientId user who requested an invite
 * @param pushText
 */
Parse.Cloud.define("acceptRequest", function(request, response) {
    Parse.Cloud.run("helper_UpdateInvitation", {"invitationId": request.params.invitationId}, {
        success: function(myObject) {
            console.log("invitation " + myObject + " destroyed");

            // Add user to the invited list
            Parse.Cloud.run("helper_AddToInvitedList", {"userId": request.params.recipientId, "partyId": request.params.partyId}, {
                success: function(party) {

                    // Notify recipient about accepted request
                    Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": ACCEPT_REQUEST_TYPE}, {
//              FORTEST      Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": ACCEPT_REQUEST_TYPE}, {
                        success: function (invitation) {

                            Parse.Cloud.run("helper_CreateIventFriendGoesToParty", {"userId": request.params.recipientId, "partyId": request.params.partyId}, {
                                success: function (event) {
                                    Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                                        success: function(result) {
                                            response.success("went well");
                                        },
                                        error: function(error) {
                                            response.success("went well, but didn't send push");
                                        }
                                    });
                                },
                                error: function (myObject, error) {
                                    console.log("object " + myObject + " error = " + error);
                                    response.error("FAILED to save Event with type = 1");
                                }
                            });

                        },
                        error: function (myObject, error) {
                            console.log("object " + myObject + " error = " + error);
                            response.error("FAILED to save Invitation with type = 1");
                        }
                    });
                },
                error: function(object, error) {
                    console.log("object " + object + " error = " + error);
                    response.error("FAILED to save party update : " + error);
                }
            });
        },
        error: function(myObject, error) {
            console.log("object " + myObject + " error = " + error);
            response.error("FAILED to destroy invitation : " + error);
        }
    });
});

/**
 * Decline user request to the party
 * @param partyId
 * @param recipientId user who requested the invite
 * @param invitationId previous invitation
 * @param pushText
 */
Parse.Cloud.define("declineRequest", function(request, response) {
    Parse.Cloud.run("helper_UpdateInvitation", {"invitationId": request.params.invitationId}, {
        success: function (myObject) {
            console.log("invitation " + myObject + " destroyed");

            Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": DECLINE_REQUEST_TYPE}, {
//      FORTEST      Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": DECLINE_REQUEST_TYPE}, {
                success: function(myOjb) {
                    Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                        success: function(result) {
                            response.success("went well");
                        },
                        error: function(error) {
                            response.success("went well, but didn't send push");
                        }
                    });
                },
                error: function(error) {
                    response.error(error);
                }
            });

        },
        error: function (myObject, error) {
            console.log("object " + myObject + " error = " + error);
            response.error("smth wrong");
        }
    });
});

/**
 * Sends a recommendation to user to visit a party
 * @param recipientId
 * @param partyId
 * @param pushText
 */
Parse.Cloud.define("sendRecommendation", function(request, response) {
    Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_RECOMMENDATION_TYPE}, {
//    TESTONLY Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": SEND_RECOMMENDATION_TYPE}, {
        success: function (myObj) {
            Parse.Cloud.run("helper_SendPush", {"recipientId": request.params.recipientId, "text": request.params.pushText}, {
                success: function(result) {
                    response.success("went well");
                },
                error: function(error) {
                    response.success("went well, but didn't send push");
                }
            });
        },
        error: function (error) {
            response.error(error);
        }
    });
});

/**
 * Follows user
 * @param userId ID of a user to follow
 * @param pushText
 *
 */
Parse.Cloud.define("followUser", function(request, response) {
    var userToFollow = new Parse.User();
    userToFollow.id = request.params.userId;

    var followRelation = request.user.relation("following");
    followRelation.add(userToFollow);

    request.user.save(null, {
        success: function(user) {
            Parse.Cloud.run("helper_SendInvite", {"senderId": request.user.id, "recipientId": userToFollow.id, "partyId": null, "type": USER_FOLLOWED_TYPE}, {
                success: function (myObj) {
                    Parse.Cloud.run("helper_SendPush", {"recipientId": userToFollow.id, "text": request.params.pushText}, {
                        success: function(result) {
                            response.success("went well");
                        },
                        error: function(error) {
                            response.success("went well, but didn't send push");
                        }
                    });
                },
                error: function (error) {
                    response.error(error);
                }
            });
        },
        error: function(gameScore, error) {
            response.error(error);
        }
    });
});

// AFTER SAVE METHODS
Parse.Cloud.afterSave("Party", function(request) {
    if (!request.object.existed()) {
        var Event = Parse.Object.extend("Event");
        var event = new Event();

//        console.log("owner " + request.user);
        console.log("owner " + request.object.get("creator"));
        console.log("party " + request.object);

        event.set("type", 0);
        event.set("owner", request.object.get("creator"));
        event.set("party", request.object);
        event.set("timePassed", "Like really a lot");

        event.save();
    }
});

Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
    // request.user is a Parse.User object. It corresponds to the currently logged in user in iOS or Android.
    if (request.user) {
        // Add a pointer to the Parse.User object in a "user" column.
        request.object.set("user", request.user);
    }

    // Proceed with saving the installation.
    response.success();
});

// Принимает на вход userId и текущую дату
// Возвращает количество followers, following, visited и created для юзера с этим id
// Формат выходной строки: followers/following/visited/created/
Parse.Cloud.define("countProfileStats", function(request, response) {
    console.log(request.params);

    var userQuery = new Parse.Query(Parse.User);
    userQuery.get(request.params.userId, {
        success: function(foundedUser) {
            var targetUser = foundedUser;

            var followersCount = 0;
            var followingCount = 0;
            var visitedCount = 0;
            var createdCount = 0;

            var followersQuery = new Parse.Query(Parse.User);
            followersQuery.equalTo  ("following", targetUser);
            followersQuery.count({
                success: function(count1) {
                    followersCount = count1;

                    var relation = targetUser.relation("following");
                    relation.query().count({
                        success: function(count2) {
                            followingCount = count2;

                            var Party = Parse.Object.extend("Party");
                            var visitedQuery = new Parse.Query(Party);
//                            visitedQuery.lessThan("date", request.params.currentDate);
                            visitedQuery.lessThan("date", new Date());
                            visitedQuery.equalTo("invited", targetUser);
                            visitedQuery.count({
                                success: function(count3) {
                                    visitedCount = count3;

                                    var createdQuery = new Parse.Query(Party);
                                    createdQuery.equalTo("creator", targetUser);
                                    createdQuery.count({
                                        success: function(count4) {
                                            createdCount = count4;

                                            var isFollowing = false;
                                            var queryFollowing = request.user.relation("following").query();
                                            queryFollowing.equalTo("objectId", request.params.userId);
                                            queryFollowing.count({
                                                success: function(isFollowed) {
                                                    if (isFollowed == 1) { isFollowing = true; }
                                                    response.success({"followers": followersCount, "following": followingCount, "visited": visitedCount, "created": createdCount, "is_followed": isFollowing});
                                                },
                                                error: function(error) {
                                                    console.error(error);
                                                    response.error("error when getting isFollowed");
                                                }
                                            });
                                        },
                                        error: function(error) {
                                            console.log("error = " + error);
                                            response.error("error when getting created count");
                                        }
                                    });
                                },
                                error: function(error) {
                                    console.log("error = " + error);
                                    response.error("error when getting visited count");
                                }
                            });
                        },
                        error: function(error) {
                            console.log("error = " + error);
                            response.error("error when getting following count");
                        }
                    });
                },
                error: function(error) {
                    console.log("error = " + error);
                    response.error("error when getting followers count");
                }
            });
        },
        error: function(object, error) {
            console.log("object " + object + " error = " + error);
            response.error("error when getting user");
        }
    });
});

/**
 * Takes partyId and returns:
 *  1. Number of free spaces
 *  2. At most 2 of your friends who go to that party
 *  3. Number of people who also go (friends from (2) are not included
 *  4. Weather user is going to the party or no
 *
 * Exp:
 * {
 *      "places_left" : 5, // if party.capacity = 0 then places_left = -1
 *      "friends" : {visor, milka},
 *      "also_go" : 8,
 *      "is_going" : true
 * }
 *
 * 5 places left
 * visor, milka and 8 others are going
 */
Parse.Cloud.define("getInvitedInfoForParty", function(request, response) {
    var places_left = 0;
    var friends = {};
    var alsoGo = 0;
    var userGoes = false;

    var Party = Parse.Object.extend("Party");
    var party = new Party();
    party.id = request.params.partyId;
    party.fetch().then(function() {
        var user = request.user;
        var followingQuery = user.relation("following").query();
        followingQuery.select("username");
        followingQuery.find().then(function(friends) {
            invitedQuery = party.relation("invited").query();
            invitedQuery.select("username");
            invitedQuery.find().then(function(invited) {
                console.log(friends);
                console.log(invited);

                friendsWhoGo = [];
                for (lastIndex = 0, i = 0; i < friends.length; i++) {
                    for (j = 0; j < invited.length; j++) {
                        if (j == i) { continue; }
                        if (friends[i].id == invited[j].id) {
                            friendsWhoGo[lastIndex++] = friends[i].get("username");
                            if (lastIndex > 1) { // we return at most two friends who go to the party
                                j = invited.length; // break out of two loops
                                i = friends.length;
                            }
                        }
                    }
                }

                for (j = 0; j < invited.length; j++) {
                    if (invited[j].id == request.user.id) {
                        userGoes = true;
                        break;
                    }
                }

                var capacity = party.get("capacity");
                places_left = (capacity == 0) ? -1 : capacity - invited.length;
                friends = friendsWhoGo;
                alsoGo  = invited.length - friends.length;

                response.success({"places_left": places_left, "friends": friends, "also_go": alsoGo, "is_going": userGoes});
            });
        });
    }, function(error) {
        response.error("The partyId you provided doesn't refer to any known parties.");
    });
});

/**
 * Returns an array of parties for particular map state
 * @param sw near left point
 * @param ne far right point
 * @param zoom
 */
Parse.Cloud.define("loadPartiesForMap", function(request, response) {
    var zoom = request.params.zoom;
    var sw   = request.params.sw;
    var ne   = request.params.ne;

    var result = {};

    console.log(sw);
    console.log(ne);

    if (zoom >= 6) {
        result.clustered = false;

        var query = new Parse.Query("Party");
        query.withinGeoBox("geoPosition", sw, ne);
        query.find({
            success: function(parties) {
                result.data = parties;
                response.success(JSON.stringify(result.toJSON()));
            }
        });
    } else {

    }

    response.success("OK");
});

/** Report functions **/

Parse.Cloud.define("report_offensive_user", function(request, response) {
    var Report = Parse.Object.extend("Reports");
    var report = new Report();
    report.set("subject", "user");
    report.set("reference", request.params.userId);
    report.set("resolved", false);
    report.save(null, {
        success: function(event) {
            console.warn("Report was saved");
            response.success();
        },
        error: function(event, error){
            console.warn("failed to create a report");
        }
    });
});

Parse.Cloud.define("report_offensive_party", function(request, response) {
    var Report = Parse.Object.extend("Reports");
    var report = new Report();
    report.set("subject", "party");
    report.set("reference", request.params.partyId);
    report.set("resolved", false);
    report.set("sender", request.user);
    report.save(null, {
        success: function(event) {
            console.warn("Report was saved");
            response.success();
        },
        error: function(event, error){
            console.warn("failed to create a report");
        }
    });
});

/******************* TEST
 *******************      FUNCTIONS *************************/

Parse.Cloud.define("createTestUsers", function(request, response) {
//    var userNics = ["Flaming Morbid Rat", "Cult Rough Rabbit", "Wombat Bare", "Sergent Wild Sparrow", "Sugar Detective", "Captain Kangaroo", "Warm Dugong", "Der Larva", "Ivory Baby", "Warm Hippopotamus", "Sad Gravy", "Camel Crunchy", "Hungry Screaming Pink", "Woodchuck Serious", "The Cat", "Massive Panther", "Rat Doctor", "Sweet Fisherman", "Slimy Fast Hook", "Sleepy Whale", "Hearty Crow", "FinchFinch", "Volunteer Princess", "Monkey Pointless", "The Seal", "Boy Brave", "SweetySweety", "Otter Orange", "Sheep Tough", "Cute Puppy", "Fast Boy", "Fisty Toddler", "Man Pet", "Chicken Pup", "Wild Elephant", "Pirate Drunken", "Foxy Beauty Titan", "El Pet", "Stud Maximum", "Major Fairy", "Needless Jockey", "Nasty Cutie Pig", "Prince Whale", "Rocky Moving Laser", "Hungry Lefty Salamander", "El Pioneer", "Goldfish Hungry"];

    var user = new Parse.User();
    user.set("username", request.params.nic);
    user.set("password", "password");

    user.signUp(null, {
        success: function(user) {
            Parse.Cloud.httpRequest({
                url: request.params.photoUrl
            }).then(function(httpResponse) {
                var Image = require("parse-image");
                var image = new Image();
                console.log(httpResponse.text);
                return image.setData(httpResponse.buffer);
            })
//                .then(function(image) {
//                return image.scale({
//                    width:200,
//                    height:200
//                });
//            })
                .then(function(image) {
                return image.data();
            }).then(function(buffer) {
                var base64 = buffer.toString("base64");
                var cropped = new Parse.File("photo100.png", { base64: base64 });
                return cropped.save();
            }).then(function(photo) {
                user.set("photo100", photo);
                user.set("photo200", photo);
                user.save().then(function(user) { response.success(user.id); });
            });
        },
        error: function(user, error) {
            console.log("Error: " + error.code + " " + error.message);
        }
    });
});

Parse.Cloud.define("followEveryone", function(request, response) {
    Parse.User.logIn(request.params.usernic, request.params.userpass, {
        success: function(logeduser) {
            var query = new Parse.Query(Parse.User);
            query.find({
                success: function(users) {
                    var relation = logeduser.relation("following");
                    for (j = 0; j < users.length; j++) {
                        if (users[j].get("username") == logeduser.get("username")) { continue; }
                        console.log("   "+logeduser.get("username") + " now follows "+users[j].get("username"));
                        relation.add(users[j]);
                    }
                    logeduser.save(null, {
                        success: function(user) {
                            console.warn("saved");
                            Parse.User.logOut();
                            response.success(request.params.usernic + " now follows everyone");
                        },
                        error: function(gameScore, error) {
                            console.error(error);
                            response.error(error);
                        }
                    });
                }
            });
        },
        error: function(user, error) {
            console.error(error);
            response.error(error);
        }
    });
});

Parse.Cloud.define("getAllUsersNics", function(request, response) {
    var query = new Parse.Query(Parse.User);
    query.find({
        success: function(users) {
            var nics = "{ \"nics\": [";
            for (j = 0; j < users.length; j++) {
                nics += users[j].get("username")+",";
            }
            nics += "]}";
            response.success(users);
        },
        error: function(user, error) {
            console.error(error);
            response.error(error);
        }
    });
});

/**
 * @param userId
 * @param partyId
 */
Parse.Cloud.define("addInvitedToParty", function(request, response) {
    var Party = Parse.Object.extend("Party");
    var party = new Party();
    party.id = request.params.partyId;
    party.fetch().then(function() {
            relation = party.relation("invited");

            var user = new Parse.User();
            user.id = request.params.userId;
            relation.add(user);

            var Event = Parse.Object.extend("Event");
            var event = new Event();
            event.set("type", 1);
            event.set("party", party);
            event.set("owner", user);
            event.set("timePassed", request.params.timePassed);
            event.save(null, {
                success: function(event) {
                    console.warn("event for user created");
                },
                error: function(event, error){
                    console.warn("failed to create event for user "+error);
                }
            });

            party.save(null, {
                success: function(user) {
                    response.success("Added users to party invited relation");
                },
                error: function(user, error) {
                    response.error(error);
                }
            });
    });

});

Parse.Cloud.define("addInvitation", function(request, response) {
    Parse.Cloud.run("helper_SendInvite", {"senderId": request.params.userId, "recipientId": request.params.recipientId, "partyId": request.params.partyId, "type": request.params.type}, {
        success: function(myOjb) {
            response.success("went well");
        },
        error: function(error) {
            response.error(error);
        }
    });

});

Parse.Cloud.define("createTestParty", function(request, response) {
    var Party = Parse.Object.extend("Party");
    var party = new Party();

    var creator = new Parse.User();
    creator.id = request.params.creatorId;

    party.set("name", request.params.name);
    party.set("creator", creator);
    party.set("date", new Date());

//    var lat = Math.floor(Math.random() * 80);
//    var lon = Math.floor(Math.random() * 170);
    var position = new Parse.GeoPoint({latitude: request.params.lat, longitude: request.params.lon});
    party.set("geoPosition", position);

    party.set("isPrivate", true);
    party.set("generalDescription", "This party was created automatically.");
    party.set("price", "100 000 000$");
    party.set("capacity", 13);
    party.set("address", "Near you!");

    party.save(null, {
        success: function(party) {

            response.success(party.id);
        },
        error: function(party, error) {
            response.error(error);
        }
    });
});

/** CRON JOB **/

Parse.Cloud.job("deleteNullData", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
    var counter = 0;

    var query = new Parse.Query("Party");
    query.each(function(party) {
        console.log(party.get("creator").id);
        status.message(party.get("name"));

        var userQuery = new Parse.Query(Parse.User);
        userQuery.equalTo("objectId", party.get("creator").id);

        // Create a trivial resolved promise as a base case.
        var promise = Parse.Promise.as();

        userQuery.find({
            success: function(results) {
                promise = promise.then(function() {
                    console.log("in user");
                    if (results.length == 0) {
                        status.message("PartyWithNoUserFound");
                    }
                    return;
                    // Return a promise that will be resolved when the delete is finished.
//                    return result.destroy();
                });
            },
            error: function(error) { console.log("error"); status.message("user look up failed with error " +error); return; }
        });

        return promise;
    }).then(function() {
        status.success("Parties look up finished");
    });

});
