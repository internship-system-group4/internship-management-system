(function () {
 'use strict';
 function field(id){return document.getElementById(id);}
 function validate(form){
  if(form.getAttribute('data-submitting')==='true')return false;
  var first=null,valid=true;
  form.querySelectorAll('[data-public-required]').forEach(function(input){
   var message='',value=input.value.trim(),error=field(input.getAttribute('aria-describedby').split(' ')[0]);
   if(!value) message=input.getAttribute('data-required-message')||'Please fill in this field.';
   else if(input.type==='email'&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) message='Enter a valid email address.';
   else if(input.minLength>0&&value.length<input.minLength) message='Please enter at least '+input.minLength+' characters.';
   if(error)error.textContent=message;
   input.setAttribute('aria-invalid',String(!!message));
   if(message){valid=false;if(!first)first=input;}
  });
  if(first)first.focus();
  if(valid){
   form.setAttribute('data-submitting','true');form.setAttribute('aria-busy','true');
   var button=form.querySelector('input[type="submit"]'),status=form.querySelector('[data-submit-status]');
   if(button){button.dataset.originalText=button.value;button.setAttribute('aria-disabled','true');button.value=form.dataset.publicForm==='contact'?'Sending message…':form.dataset.publicForm==='login'?'Signing in…':'Requesting reset link…';}
   if(status)status.textContent='Sending your message. Please wait for confirmation.';
  }
  return valid;
 }
 window.validateLogin=function(){return validate(document.querySelector('[data-public-form]'));};
 window.validateEmail=window.validateLogin;
 window.validateContact=window.validateLogin;
 document.querySelectorAll('[data-public-required]').forEach(function(input){
  input.addEventListener('input',function(){input.removeAttribute('aria-invalid');var error=field(input.getAttribute('aria-describedby').split(' ')[0]);if(error)error.textContent='';});
 });
 var toggle=field('toggleButton');
 if(toggle)toggle.addEventListener('click',function(){
  var password=field(toggle.getAttribute('aria-controls')),show=password.type==='password';
  password.type=show?'text':'password';toggle.textContent=show?'Hide':'Show';
  toggle.setAttribute('aria-pressed',String(show));toggle.setAttribute('aria-label',show?'Hide password':'Show password');
 });
 function resetBusy(){document.querySelectorAll('[data-public-form]').forEach(function(form){
  form.removeAttribute('data-submitting');form.removeAttribute('aria-busy');
  var button=form.querySelector('input[type="submit"]');if(button){button.removeAttribute('aria-disabled');if(button.dataset.originalText)button.value=button.dataset.originalText;}
  var status=form.querySelector('[data-submit-status]');if(status)status.textContent='';
 });}
 document.addEventListener('invalid',resetBusy,true);window.addEventListener('pageshow',resetBusy);
 var alert=document.querySelector('[data-public-form] [role="alert"]');
 if(alert){alert.tabIndex=-1;alert.focus();}
}());

