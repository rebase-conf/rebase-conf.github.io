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
    var $this = $(this);
    $personEl = $this.closest('.box__person');
    fillPersonOverlay($personEl);
    showOverlay('.overlay--person', $this.attr('href'));
  });

  $('[data-overlay=talk]').click(function (e) {
    e.preventDefault();
    var $this = $(this);
    $talkEl = $this.closest('.box');
    fillTalkOverlay($talkEl);
    showOverlay('.overlay--talk', $this.attr('href'));
  });

  $('.overlay').click(function (e) {
    var $target = $(e.target);
    if (!$target.hasClass('overlay__close') && $(e.target).closest('.box').length === 0) {
      closeOverlay();
    }
  });

  if(window.location.hash) {
    var $overlayLink = $('[data-overlay][href="' + window.location.hash + '"]');
    if($overlayLink.length) {
      var $parent = $overlayLink.closest('.box');
      $('html,body').scrollTop($parent.offset().top);
      $overlayLink[0].click();
    }
  }
});

closeOverlay = function() {
  $('.overlay').removeClass('overlay--active');
  var $body = $('body');
  var scrollPosition = -1 * parseInt($body.css('marginTop'));
  $body.removeClass('body--overlay-active').css({marginTop: 0});
  $('html,body').scrollTop(scrollPosition);
  window.history.replaceState({}, null, window.location.pathname);
}

showOverlay = function(overlay, href) {
  var $overlay = $(overlay);
  scrollPosition = $('html').scrollTop();
  $overlay.addClass('overlay--active');
  $('.overlay__content-scroll').scrollTop(0);
  $('body').addClass('body--overlay-active').css({marginTop: -scrollPosition});
  window.history.replaceState({}, null, href);
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
