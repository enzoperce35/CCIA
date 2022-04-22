data_arr = []
id_arr = []
  
var css_root = document.querySelector(':root');
var css_data = getComputedStyle(css_root);
  
var data = css_data.getPropertyValue('--data');
var index = css_data.getPropertyValue('--index');

data_arr.push(data)
id_arr.push(Number(index))
render_data(data_arr, id_arr);

function render_data(data_arr, id_arr) {
  data_arr.forEach((data, index) => {
    const id = id_arr[index]
   
     document.getElementById("prog-" + id).style.width = data;
  });
};
