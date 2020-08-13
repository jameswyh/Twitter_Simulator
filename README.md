# Proj 4.2 - Twitter

## YouTube link for demo video:
https://youtu.be/7eR-p9tnmZs 

## 1. Group members
Yihui Wang UFID# 8316-4355   
Wei Zhao UFID# 9144-4835

## 2. Steps to run code
1. Open the Terminal and go to the directory of the project.
2. Type in the following command:
```
mix phx.server
```
If there are any prompt asking to install dependencies. please install them.
3. Open the web browser and visit [`localhost:4000`](http://localhost:4000)

## 3. What function was implemented and how to run them
1. Register Account: To register user, input your username and password with space in between. Then click "Register Account" to register. For example, if the username is"111", password is "222", input: 
```
111 222
```
2. Delete Account: To delete account, simply input the current user's password and click "Delete Account"
3. Tweet: Type in the tweet you want to send and click "Tweet" button to send a new tweet. Tweets can have hashtags (e.g. COP5615isgreat) and mentions(@bestuser).
4. Retweet: Input the index number in the tweet list and click "Retweet" to retweet that tweet.
5. Subscribe: Input the username you want to follow and click "Subscribe".
6. Query Subscribed: Simply click this button to see the users you subcribed.
7. Query Hashtag: Input the name of hashtag topic (without the # symbol) and click Query Hashtag to see all related tweets for this topic.
8. Query Mention: Input the username (without the "@" symbol) and click "Query Mention"" to see all the tweets that mentioned that user.

## 4. Implement a simulation with at least 100 users.
Please see attached "performance.pdf" for the simulation.
