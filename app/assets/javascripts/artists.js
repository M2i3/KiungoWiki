/*
  Editing Artists
*/
'use strict';
var artistModule = angular.module('kwArtist', [
  'ngRoute', 
  'ngResource'  
]);

artistModule.factory('artist', ['$resource',function($resource){
  return $resource('/artists/:id', { id: "@id" },
    {
      'create':  { method: 'POST' },
      'index':   { method: 'GET', isArray: true },
      'show':    { method: 'GET', isArray: false },
      'update':  { method: 'PUT' },
      'destroy': { method: 'DELETE' }
    }
  );
}]);

artistModule.controller('ArtistFormCtrl', ['$scope', 'artist', function($scope, artist) {
  
  $scope.getWikiLinkID = function(wikiLink) {
    return wikiLink._id + wikiLink.signature;
  }
  
  
  $scope.increment = function() {
/*    if (getPageJSONContent() != "") {
      $http.get(getPageJSONContent()).success(function(data) {
        $scope.counter = data.signature;
      });
    }
*/
    
    /*
    randomData.get(function(data) {
      $scope.counter = data.text;
    });
    */
  }
 
  $scope.counter = "(unknown)"; 

  if (getMetaTagValue("json-src")) {
    artist.show({id: getMetaTagValue("json-src")}, function(data){
      $scope.artist = data;
    });
  }


  
}]);