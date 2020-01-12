var scrollPosition;

$(document).ready(function () {
  $('.button--inactive').click(function(e) {
    e.preventDefault();
  });

  $('.overlay__close').click(function(e) {
    e.preventDefault();
    closeOverlay();
  });

  $('[data-overlay=person]').click(function (e) {
    e.preventDefault();
    $personEl = $(this).closest('.box__person');
    fillPersonOverlay($personEl);
    showOverlay('.overlay--person');
  });

  $('[data-overlay=talk]').click(function (e) {
    e.preventDefault();
    $talkEl = $(this).closest('.box');
    fillTalkOverlay($talkEl);
    showOverlay('.overlay--talk');
  });

  $('.overlay').click(function (e) {
    if ($(e.target).closest('.box').length === 0) {
      closeOverlay();
    }
  });
});

closeOverlay = function() {
  $('.overlay').removeClass('overlay--active');
  $('body').removeClass('body--overlay-active').css({marginTop: 0});
  $('html,body').scrollTop(scrollPosition);
}

showOverlay = function(overlay) {
  var $overlay = $(overlay);
  scrollPosition = $('html').scrollTop();
  $overlay.addClass('overlay--active');
  $('.overlay__content-scroll').scrollTop(0);
  $('body').addClass('body--overlay-active').css({marginTop: -scrollPosition});
};

fillPersonOverlay = function ($personEl) {
  var $overlay = $('.overlay--person');
  var $clone = $personEl.clone();
  $clone.find('.box__person-name').unwrap();
  $clone.find('[data-overlay]').remove();
  $overlay.find('.box__person').replaceWith($clone);
  var speaker = speakers[$personEl.attr('data-id')];
  $overlay.find('.box__text-content').empty().append(speaker);
};

fillTalkOverlay = function($talkEl) {
  var $overlay = $('.overlay--talk');
  var $clone = $talkEl.clone();
  $clone.find('.box__text-content').remove();
  $clone.find('.box__text-heading').unwrap();
  $clone.find('.box__text-links [data-overlay]').remove();
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
