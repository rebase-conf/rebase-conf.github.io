$(document).ready(function () {
  $('.button--inactive').click(function(e) {
    e.preventDefault();
  });

  $('.box__person-links [data-overlay=person]').click(function (e) {
    e.preventDefault();
    $personEl = $(this).closest('.box__person');
    fillPersonOverlay($personEl);
    $('.overlay--person').toggleClass('overlay--active');
  });

  $('a[href="#abstract"]').click(function (e) {
    e.preventDefault();
    $talkEl = $(this).closest('.box');
    fillTalkOverlay($talkEl);
    $('.overlay--talk').toggleClass('overlay--active');
  });

  $('.overlay').click(function (e) {
    if (e.target === e.currentTarget) {
      $(this).toggleClass('overlay--active');
    }
  });
});

fillPersonOverlay = function ($personEl) {
  var $overlay = $('.overlay--person');
  var $clone = $personEl.clone();
  $clone.find('.box__text-links [data-overlay=person]').remove();
  $overlay.find('.box__person').replaceWith($clone);
  var speaker = speakers[$personEl.attr('data-id')];
  $overlay.find('.box__text-content').empty().append(speaker);
};

fillTalkOverlay = function($talkEl) {
  var $overlay = $('.overlay--talk');
  var $clone = $talkEl.clone();
  $clone.find('.box__text-links [data-overlay=talk]').remove();
  var $box = $overlay.find('.box');
  $box.empty()
  $box.append($clone.children());
  $text = $('<div class="box__text-content"></div>');
  talk = talks[$talkEl.attr('data-id')];
  $text.append('<h3>Abstract</h3>');
  $text.append(talk.abstract);
  talk.speakers.forEach(function(speaker) {
    $text.append('<h3>About ' + speaker.name + '</h3>');
    $text.append(speaker.bio);
  });
  $box.append($text);
};
