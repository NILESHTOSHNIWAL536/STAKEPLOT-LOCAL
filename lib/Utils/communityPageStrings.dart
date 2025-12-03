import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import '../routes/route_constant.dart'; // For url

class CommunityScreenStrings {
  static final CommunityScreenStrings _instance =
      CommunityScreenStrings._internal();

  factory CommunityScreenStrings() => _instance;

  CommunityScreenStrings._internal();

  // Community Screen
  String welcomeBack = "Welcome back to";
  String finspace = "Finspace";
  String searchHint = "Search";
  String featuredPosts = "Featured Posts";
  String noFriendsMessage = "Make friends to see their posts or upload post";
  String createPost = "Create Post";
  String textOption = "Write";
  String imageOption = "Image";
  String pollOption = "Poll";
  String exploria = "Exploria";
  String writePost = "Write a Post";
  String createPoll = "Create Poll";
  String postCard = "Post Card";

  String postExploria = "Post Exploria";
  // TextScreen and ImageScreen (shared)
  String newPost = "New post";
  String enterTitle = "Enter title ";
  String addThoughts = "Add description";
  String continueButton = "Continue";
  String postedSuccess = "Posted";
  String trending = "Now";
  String feed = "ForYou";
  String maskeduser = "maskeduser";
  String All = "All";
  int limitTag = 3;
  // PollScreen
  String askQuestion = "Ask a question";
  String optionPrefix = "Option";
  String addOption = "Add Option";
  String pollIncompleteError =
      "Please fill in all fields before posting the poll.";

  // ExploreModal
  String photosLabel = "Photos ({count}/5)";
  String noImagesSelected = "No images selected";
  String addPhoto = "Add Photo";
  String cancelButton = "Cancel";
  String saveButton = "Save";
  String aboutPlace = "About Place";
  String locationName = "Location Name";
  String locationAddress = "Location Address";
  String budgetLabel = "Budget";
  String addCategory = "Add Category";
  String addBudget = "Add Budget";
  String tripHighlights = "Trip Highlights";
  String rateThisPlace = "Rate this place:";
// tribechat
  String messagesTitle = "Messages";
  String messagesReceived = "{count} message(s) received";
  String noChatsAvailable = "Oops! Inbox is empty";
  String noMessagesYet = "No messages yet";

  //chat
  String chatHi = "Messages";
  String rupeeSymbol = "₹";
  String totalExpenseSplit = "Total expense: ";
  String shareSplit = "Share: ";
  String settleStatus = "Settled Successfully";
  String pendingStatus = "Pending";
  String imageSendQue = "Do you want to send this?";
  String cancel = "Cancel";
  String send = "Send";

  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.community);
      
      if (getFlagOfResponse(response)) {
        var data = jsonDecode(response.body)['data'] ?? {};
        limitTag = data['limitTag'] ?? limitTag;
        // Community Screen
        welcomeBack = data['welcomeBack'] ?? welcomeBack;
        finspace = data['finspace'] ?? finspace;
        searchHint = data['searchHint'] ?? searchHint;
        featuredPosts = data['featuredPosts'] ?? featuredPosts;
        noFriendsMessage = data['noFriendsMessage'] ?? noFriendsMessage;
        createPost = data['createPost'] ?? createPost;
        textOption = data['textOption'] ?? textOption;
        imageOption = data['imageOption'] ?? imageOption;
        pollOption = data['pollOption'] ?? pollOption;
        exploria = data['exploria'] ?? exploria;
        writePost = data['writePost'] ?? writePost;
        createPoll = data['createPoll'] ?? createPoll;
        postCard = data['postCard'] ?? postCard;
        postExploria = data['postExploria'] ?? postExploria;

        // TextScreen and ImageScreen
        newPost = data['newPost'] ?? newPost;
        enterTitle = data['enterTitle'] ?? enterTitle;
        addThoughts = data['addThoughts'] ?? addThoughts;
        continueButton = data['continueButton'] ?? continueButton;
        postedSuccess = data['postedSuccess'] ?? postedSuccess;

        // PollScreen
        askQuestion = data['askQuestion'] ?? askQuestion;
        optionPrefix = data['optionPrefix'] ?? optionPrefix;
        addOption = data['addOption'] ?? addOption;
        pollIncompleteError =
            data['pollIncompleteError'] ?? pollIncompleteError;

        // ExploreModal
        photosLabel = data['photosLabel'] ?? photosLabel;
        noImagesSelected = data['noImagesSelected'] ?? noImagesSelected;
        addPhoto = data['addPhoto'] ?? addPhoto;
        cancelButton = data['cancelButton'] ?? cancelButton;
        saveButton = data['saveButton'] ?? saveButton;
        aboutPlace = data['aboutPlace'] ?? aboutPlace;
        locationName = data['locationName'] ?? locationName;
        locationAddress = data['locationAddress'] ?? locationAddress;
        budgetLabel = data['budgetLabel'] ?? budgetLabel;
        addCategory = data['addCategory'] ?? addCategory;
        addBudget = data['addBudget'] ?? addBudget;
        tripHighlights = data['tripHighlights'] ?? tripHighlights;
        rateThisPlace = data['rateThisPlace'] ?? rateThisPlace;
//tribe chat
        messagesTitle = data['messagesTitle'] ?? messagesTitle;
        messagesReceived = data['messagesReceived'] ?? messagesReceived;
        noChatsAvailable = data['noChatsAvailable'] ?? noChatsAvailable;
        noMessagesYet = data['noMessagesYet'] ?? noMessagesYet;

        //chat
        chatHi = data['chatHi'] ?? chatHi;
        rupeeSymbol = data['rupeeSymbol'] ?? rupeeSymbol;
        totalExpenseSplit = data['totalExpenseSplit'] ?? totalExpenseSplit;
        shareSplit = data['shareSplit'] ?? shareSplit;
        settleStatus = data['settleStatus'] ?? settleStatus;
        pendingStatus = data['pendingStatus'] ?? pendingStatus;
        imageSendQue = data['imageSendQue'] ?? imageSendQue;
        shareSplit = data['shareSplit'] ?? shareSplit;
        cancel = data['cancel'] ?? cancel;

        send = data['send'] ?? send;

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
