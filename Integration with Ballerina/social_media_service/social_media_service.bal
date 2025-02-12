import ballerina/http;
import ballerina/time;

type User record {
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
};

type NewUser record {

    string name;
    time:Date birthDate;
    string mobileNumber;
};



table<User> key(id) & readonly users = table [
    {id: 1, name: "Joe", birthDate: {year: 1990, month: 10, day: 10}, mobileNumber: "0771234567"}
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};


// UserNotFound is become subtype of http:NotFound it like super class and xub class in OOP
// Using this kind od things we can add additional informations
type UserNotFound record {
    *http:NotFound;
    ErrorDetails body;
};

service /social\-media on new http:Listener(9090) {
    isolated resource function get users() returns User[]|error {
        return users.toArray();
    }

    isolated resource function get users/[int id]() returns http:Ok|http:NotFound|error {
        User? user = users[id];

        if user is () {
            return <http:NotFound>{
                body: {
                    message: string `id: ${id}`,
                    details: string `user/${id}`,
                    timeStamp: time:utcNow()
                }
            };
        }
        return <http:Ok>{
            body: user
        };
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.size() + 1, ...newUser});
        return http:CREATED;

    }

    }

