$(function(){
  $('.js_fast_online_submit_photos').on("click", function(){
    if (confirm('确定执行操作么?')!= true) {
      return
    }
    
    var submit_date = [];

    $('.js_fast_online_image_block').each(function() {
      var _this = $(this);
      var file_path = _this.attr('fpath');
      var room_id = _this.find('.js_fast_online_room_select').val();
      var info = {};

      if(room_id.length > 0){
        info['file_path'] = file_path;
        info['room_id'] = room_id;
        submit_date.push(info);
      }
    });

    $.ajax({
      url: '/houses/update_sight_photos',
      type: 'PUT',
      data: {room_photos: JSON.stringify(submit_date)},
      dataType: 'json',
      success: function(data, textStatus, xhr){
        if(data.status == 'success'){
          alert('操作成功');
          location.reload(true);
        }else{
          alert(data.msg);
        }
      }
    })
  });
});
